/// Main game state provider
/// Manages player data, progression, achievements, and persistence
library;

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';
import '../models/truck_model.dart';
import '../models/trailer_model.dart';
import '../models/achievement_model.dart';
import '../config/game_config.dart';

class GameStateProvider extends ChangeNotifier {
  // Player data
  late PlayerModel _player;
  PlayerModel get player => _player;

  // Available trucks and trailers
  late List<TruckModel> _availableTrucks;
  List<TruckModel> get availableTrucks => _availableTrucks;

  late List<TrailerModel> _availableTrailers;
  List<TrailerModel> get availableTrailers => _availableTrailers;

  // Achievements
  late List<Achievement> _achievements;
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  // Current game session data
  bool _isInGame = false;
  bool get isInGame => _isInGame;

  GameMode _currentGameMode = GameMode.freePlay;
  GameMode get currentGameMode => _currentGameMode;

  // Initialization
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  GameStateProvider() {
    _initializeDefaultData();
  }

  /// Initialize with default data
  void _initializeDefaultData() {
    _player = PlayerModel.newPlayer();
    _availableTrucks = List.from(TruckTemplates.allTrucks);
    _availableTrailers = List.from(TrailerTemplates.allTrailers);
    _achievements = List.from(AchievementTemplates.allAchievements);
    _isInitialized = true;
  }

  /// Load game data from storage
  Future<void> loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = prefs.getString('player_data');
      final trucksJson = prefs.getString('trucks_data');
      final trailersJson = prefs.getString('trailers_data');
      final achievementsJson = prefs.getString('achievements_data');

      if (playerJson != null) {
        _player = PlayerModel.fromJson(json.decode(playerJson));
      }

      if (trucksJson != null) {
        final List<dynamic> trucksData = json.decode(trucksJson);
        _availableTrucks = trucksData.map((truckData) {
          final template =
              TruckTemplates.getTruckById(truckData['id']) ??
                  TruckTemplates.getDefaultTruck();
          return TruckModel.fromJson(truckData, template);
        }).toList();
      }

      if (trailersJson != null) {
        final List<dynamic> trailersData = json.decode(trailersJson);
        _availableTrailers = trailersData.map((trailerData) {
          final template =
              TrailerTemplates.getTrailerById(trailerData['id']) ??
                  TrailerTemplates.getDefaultTrailer();
          return template.copyWith(
            isUnlocked: trailerData['isUnlocked'] ?? false,
          );
        }).toList();
      }

      if (achievementsJson != null) {
        final List<dynamic> achievementsData = json.decode(achievementsJson);
        _achievements = achievementsData.map((achievementData) {
          final template =
              AchievementTemplates.getAchievementById(achievementData['id']);
          return template != null
              ? Achievement.fromJson(achievementData, template)
              : template!;
        }).toList();
      }

      // Check and complete any repairs that finished while app was closed
      _player.checkAndCompleteRepair();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading game data: $e');
      _initializeDefaultData();
    }
  }

  /// Save game data to storage
  Future<void> saveGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('player_data', json.encode(_player.toJson()));

      await prefs.setString(
        'trucks_data',
        json.encode(_availableTrucks.map((t) => t.toJson()).toList()),
      );

      await prefs.setString(
        'trailers_data',
        json.encode(_availableTrailers.map((t) => t.toJson()).toList()),
      );

      await prefs.setString(
        'achievements_data',
        json.encode(_achievements.map((a) => a.toJson()).toList()),
      );

      debugPrint('Game data saved successfully');
    } catch (e) {
      debugPrint('Error saving game data: $e');
    }
  }

  /// Get current truck
  TruckModel? getCurrentTruck() {
    try {
      return _availableTrucks.firstWhere(
        (truck) => truck.id == _player.currentTruckId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get current trailer
  TrailerModel? getCurrentTrailer() {
    try {
      return _availableTrailers.firstWhere(
        (trailer) => trailer.id == _player.currentTrailerId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Select a truck
  void selectTruck(String truckId) {
    final truck = _availableTrucks.firstWhere(
      (t) => t.id == truckId,
      orElse: () => TruckTemplates.getDefaultTruck(),
    );

    if (truck.isUnlocked) {
      _player.currentTruckId = truckId;
      _player.truckDamage.fullRepair(); // Fresh truck
      notifyListeners();
      saveGameData();
    }
  }

  /// Select a trailer
  void selectTrailer(String trailerId) {
    final trailer = _availableTrailers.firstWhere(
      (t) => t.id == trailerId,
      orElse: () => TrailerTemplates.getDefaultTrailer(),
    );

    if (trailer.isUnlocked) {
      _player.currentTrailerId = trailerId;
      notifyListeners();
      saveGameData();
    }
  }

  /// Purchase and unlock a truck
  bool purchaseTruck(String truckId) {
    final truckIndex = _availableTrucks.indexWhere((t) => t.id == truckId);
    if (truckIndex == -1) return false;

    final truck = _availableTrucks[truckIndex];

    // Check requirements
    if (truck.isUnlocked) return false;
    if (_player.damagePoints < truck.unlockCost) return false;
    if (_player.careerStage.index < truck.requiredStage.index) return false;

    // Purchase
    _player.damagePoints -= truck.unlockCost;
    _availableTrucks[truckIndex] = truck.copyWith(isUnlocked: true);

    notifyListeners();
    saveGameData();
    return true;
  }

  /// Purchase and unlock a trailer
  bool purchaseTrailer(String trailerId) {
    final trailerIndex =
        _availableTrailers.indexWhere((t) => t.id == trailerId);
    if (trailerIndex == -1) return false;

    final trailer = _availableTrailers[trailerIndex];

    if (trailer.isUnlocked) return false;
    if (_player.damagePoints < trailer.unlockCost) return false;
    if (_player.careerStage.index < trailer.requiredStage.index) return false;

    _player.damagePoints -= trailer.unlockCost;
    _availableTrailers[trailerIndex] = trailer.copyWith(isUnlocked: true);

    notifyListeners();
    saveGameData();
    return true;
  }

  /// Start a game session
  void startGame(GameMode mode) {
    _currentGameMode = mode;
    _isInGame = true;

    // Check if truck is repaired
    _player.checkAndCompleteRepair();

    notifyListeners();
  }

  /// End game session and record results
  void endGame({
    required int dpEarned,
    required int cashEarned,
    required int distanceDriven,
  }) {
    _player.completeRun(
      dpEarned: dpEarned,
      cashEarned: cashEarned,
      distanceDriven: distanceDriven,
    );

    _isInGame = false;
    notifyListeners();
    saveGameData();
  }

  /// Track achievement progress
  void trackAchievement(String achievementId, [int increment = 1]) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = _achievements[index];
    if (!achievement.isUnlocked) {
      achievement.incrementProgress(increment);

      // If just unlocked, award rewards
      if (achievement.isUnlocked) {
        _player.damagePoints += achievement.dpReward;
        _player.cash += achievement.cashReward;

        // TODO: Unlock customization items from rewards

        debugPrint('Achievement unlocked: ${achievement.name}');
      }

      notifyListeners();
      saveGameData();
    }
  }

  /// Increment bridge hit counter and track achievement
  void recordBridgeHit() {
    _player.bridgesHit++;
    trackAchievement('can_opener_apprentice');
    trackAchievement('bridge_collector');
    trackAchievement('swift_justice');
    notifyListeners();
  }

  /// Increment four-wheeler destroyed counter
  void recordFourWheelerDestroyed() {
    _player.fourWheelersDestroyed++;
    trackAchievement('four_wheeler_bowling');
    notifyListeners();
  }

  /// Increment sign destroyed counter
  void recordSignDestroyed() {
    _player.signsDestroyed++;
    trackAchievement('sign_language');
    notifyListeners();
  }

  /// Record dispatcher call ignored
  void recordDispatcherIgnored() {
    _player.dispatcherCallsIgnored++;
    trackAchievement('ignored_call');
    notifyListeners();
  }

  /// Trigger rage quit
  void rageQuit(int dpEarned) {
    _player.rageQuit(dpEarned: dpEarned);
    trackAchievement('rage_quit');
    notifyListeners();
    saveGameData();
  }

  /// Instant repair with premium currency
  bool instantRepair() {
    final success = _player.instantRepair();
    if (success) {
      notifyListeners();
      saveGameData();
    }
    return success;
  }

  /// Reset all data (for testing/debugging)
  void resetAllData() {
    _initializeDefaultData();
    notifyListeners();
    saveGameData();
  }

  /// Get statistics for display
  Map<String, dynamic> getStatistics() {
    return {
      'careerStage': _player.getCareerStageTitle(),
      'runsCompleted': _player.runsCompleted,
      'totalDistance': _player.totalDistanceDriven,
      'totalDP': _player.totalDamagePointsEarned,
      'bridgesHit': _player.bridgesHit,
      'carsDestroyed': _player.fourWheelersDestroyed,
      'signsDestroyed': _player.signsDestroyed,
      'achievementsUnlocked': unlockedAchievements.length,
      'totalAchievements': _achievements.length,
    };
  }
}
