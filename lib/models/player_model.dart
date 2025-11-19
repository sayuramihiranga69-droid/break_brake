/// Player career and progression model
library;

import '../config/game_config.dart';
import 'truck_model.dart';
import 'trailer_model.dart';
import 'damage_model.dart';

class PlayerModel {
  // Career progression
  CareerStage careerStage;
  int runsCompleted;
  int totalDistanceDriven; // in miles

  // Current equipment
  String currentTruckId;
  String currentTrailerId;
  TruckDamage truckDamage;

  // Repair system (idle mechanic)
  DateTime? repairStartTime;
  int? repairDurationMinutes;
  bool get isUnderRepair =>
      repairStartTime != null && !isRepairComplete();

  // Currency
  int damagePoints; // Main currency earned from chaos
  int cash; // Secondary currency
  int premiumCurrency; // Optional IAP currency

  // ELD system
  int eldDriveTimeRemaining; // in minutes
  DateTime? eldLastReset;
  bool get isInViolation => eldDriveTimeRemaining <= 0;

  // Statistics
  int totalDamagePointsEarned;
  int bridgesHit;
  int fourWheelersDestroyed;
  int signsDestroyed;
  int dispatcherCallsIgnored;
  int eldViolations;

  // Settings
  bool gyroEnabled;
  double gyroSensitivity;
  double musicVolume;
  double sfxVolume;

  PlayerModel({
    this.careerStage = CareerStage.companyDriver,
    this.runsCompleted = 0,
    this.totalDistanceDriven = 0,
    required this.currentTruckId,
    required this.currentTrailerId,
    TruckDamage? truckDamage,
    this.repairStartTime,
    this.repairDurationMinutes,
    this.damagePoints = 0,
    this.cash = 1000, // Starting cash
    this.premiumCurrency = 0,
    this.eldDriveTimeRemaining = GameConfig.eldDriveTimeLimit,
    this.eldLastReset,
    this.totalDamagePointsEarned = 0,
    this.bridgesHit = 0,
    this.fourWheelersDestroyed = 0,
    this.signsDestroyed = 0,
    this.dispatcherCallsIgnored = 0,
    this.eldViolations = 0,
    this.gyroEnabled = false,
    this.gyroSensitivity = 0.5,
    this.musicVolume = 0.7,
    this.sfxVolume = 0.8,
  }) : truckDamage = truckDamage ?? TruckDamage();

  /// Check if repair is complete
  bool isRepairComplete() {
    if (repairStartTime == null || repairDurationMinutes == null) {
      return true;
    }

    final completionTime =
        repairStartTime!.add(Duration(minutes: repairDurationMinutes!));
    return DateTime.now().isAfter(completionTime);
  }

  /// Get remaining repair time in minutes
  int getRemainingRepairTime() {
    if (repairStartTime == null || repairDurationMinutes == null) {
      return 0;
    }

    final completionTime =
        repairStartTime!.add(Duration(minutes: repairDurationMinutes!));
    final remaining = completionTime.difference(DateTime.now()).inMinutes;
    return remaining < 0 ? 0 : remaining;
  }

  /// Complete repair if time has elapsed
  void checkAndCompleteRepair() {
    if (isRepairComplete()) {
      truckDamage.fullRepair();
      repairStartTime = null;
      repairDurationMinutes = null;
    }
  }

  /// Start repair process
  void startRepair() {
    repairStartTime = DateTime.now();
    repairDurationMinutes = truckDamage.repairTimeMinutes;
  }

  /// Instant repair with premium currency
  bool instantRepair({int cost = 50}) {
    if (premiumCurrency >= cost) {
      premiumCurrency -= cost;
      truckDamage.fullRepair();
      repairStartTime = null;
      repairDurationMinutes = null;
      return true;
    }
    return false;
  }

  /// Complete a run
  void completeRun({
    required int dpEarned,
    required int cashEarned,
    required int distanceDriven,
  }) {
    runsCompleted++;
    totalDistanceDriven += distanceDriven;
    damagePoints += dpEarned;
    cash += cashEarned;
    totalDamagePointsEarned += dpEarned;

    // Check for career progression
    _checkCareerProgression();

    // Start repair if truck is damaged
    if (truckDamage.totalDamage > 0) {
      startRepair();
    }
  }

  /// Check if player should advance career stage
  void _checkCareerProgression() {
    if (careerStage == CareerStage.companyDriver &&
        runsCompleted >= GameConfig.companyDriverRunsRequired) {
      careerStage = CareerStage.leaseOperator;
    } else if (careerStage == CareerStage.leaseOperator &&
        runsCompleted >= GameConfig.leaseOperatorRunsRequired) {
      careerStage = CareerStage.ownerOperator;
    }
  }

  /// "Rage Quit" mechanic - instant jump to next tier
  void rageQuit({required int dpEarned}) {
    damagePoints += dpEarned;
    totalDamagePointsEarned += dpEarned;

    if (careerStage == CareerStage.companyDriver) {
      careerStage = CareerStage.leaseOperator;
      runsCompleted = GameConfig.companyDriverRunsRequired;
    } else if (careerStage == CareerStage.leaseOperator) {
      careerStage = CareerStage.ownerOperator;
      runsCompleted = GameConfig.leaseOperatorRunsRequired;
    }
  }

  /// Reset ELD timer
  void resetELD() {
    eldDriveTimeRemaining = GameConfig.eldDriveTimeLimit;
    eldLastReset = DateTime.now();
  }

  /// Consume ELD time
  void consumeELDTime(int minutes) {
    eldDriveTimeRemaining -= minutes;
    if (eldDriveTimeRemaining < 0) {
      eldViolations++;
      eldDriveTimeRemaining = 0;
    }
  }

  /// Get career stage display info
  String getCareerStageTitle() {
    switch (careerStage) {
      case CareerStage.companyDriver:
        return GameStrings.companyDriverTitle;
      case CareerStage.leaseOperator:
        return GameStrings.leaseOperatorTitle;
      case CareerStage.ownerOperator:
        return GameStrings.ownerOperatorTitle;
    }
  }

  /// Check if dispatcher should be active
  bool get isDispatcherActive =>
      careerStage == CareerStage.companyDriver ||
      careerStage == CareerStage.leaseOperator;

  /// Get dispatcher harassment frequency (lower = more frequent)
  int get dispatcherCallIntervalSeconds {
    switch (careerStage) {
      case CareerStage.companyDriver:
        return 120; // Every 2 minutes - ANNOYING
      case CareerStage.leaseOperator:
        return 300; // Every 5 minutes - less frequent
      case CareerStage.ownerOperator:
        return 0; // SILENCED
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'careerStage': careerStage.name,
      'runsCompleted': runsCompleted,
      'totalDistanceDriven': totalDistanceDriven,
      'currentTruckId': currentTruckId,
      'currentTrailerId': currentTrailerId,
      'truckDamage': truckDamage.toJson(),
      'repairStartTime': repairStartTime?.toIso8601String(),
      'repairDurationMinutes': repairDurationMinutes,
      'damagePoints': damagePoints,
      'cash': cash,
      'premiumCurrency': premiumCurrency,
      'eldDriveTimeRemaining': eldDriveTimeRemaining,
      'eldLastReset': eldLastReset?.toIso8601String(),
      'totalDamagePointsEarned': totalDamagePointsEarned,
      'bridgesHit': bridgesHit,
      'fourWheelersDestroyed': fourWheelersDestroyed,
      'signsDestroyed': signsDestroyed,
      'dispatcherCallsIgnored': dispatcherCallsIgnored,
      'eldViolations': eldViolations,
      'gyroEnabled': gyroEnabled,
      'gyroSensitivity': gyroSensitivity,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      careerStage: CareerStage.values
          .firstWhere((e) => e.name == json['careerStage']),
      runsCompleted: json['runsCompleted'],
      totalDistanceDriven: json['totalDistanceDriven'],
      currentTruckId: json['currentTruckId'],
      currentTrailerId: json['currentTrailerId'],
      truckDamage: TruckDamage.fromJson(json['truckDamage']),
      repairStartTime: json['repairStartTime'] != null
          ? DateTime.parse(json['repairStartTime'])
          : null,
      repairDurationMinutes: json['repairDurationMinutes'],
      damagePoints: json['damagePoints'],
      cash: json['cash'],
      premiumCurrency: json['premiumCurrency'] ?? 0,
      eldDriveTimeRemaining: json['eldDriveTimeRemaining'],
      eldLastReset: json['eldLastReset'] != null
          ? DateTime.parse(json['eldLastReset'])
          : null,
      totalDamagePointsEarned: json['totalDamagePointsEarned'] ?? 0,
      bridgesHit: json['bridgesHit'] ?? 0,
      fourWheelersDestroyed: json['fourWheelersDestroyed'] ?? 0,
      signsDestroyed: json['signsDestroyed'] ?? 0,
      dispatcherCallsIgnored: json['dispatcherCallsIgnored'] ?? 0,
      eldViolations: json['eldViolations'] ?? 0,
      gyroEnabled: json['gyroEnabled'] ?? false,
      gyroSensitivity: json['gyroSensitivity'] ?? 0.5,
      musicVolume: json['musicVolume'] ?? 0.7,
      sfxVolume: json['sfxVolume'] ?? 0.8,
    );
  }

  /// Create default new player
  factory PlayerModel.newPlayer() {
    return PlayerModel(
      currentTruckId: TruckTemplates.getDefaultTruck().id,
      currentTrailerId: TrailerTemplates.getDefaultTrailer().id,
    );
  }
}
