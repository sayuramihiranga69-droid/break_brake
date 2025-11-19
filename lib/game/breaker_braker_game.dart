/// Main Flame game class
/// Handles game loop, rendering, and core game logic
library;

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/game_config.dart';
import '../providers/game_state_provider.dart';
import '../components/truck/truck_component.dart';
import '../components/truck/trailer_component.dart';
import '../components/environment/road_component.dart';
import '../components/obstacles/traffic_spawner.dart';
import '../components/effects/screen_shake.dart';
import '../components/effects/collision_particle.dart';
import '../components/ui/game_hud.dart';
import '../models/truck_model.dart';
import '../models/trailer_model.dart';
import '../services/haptic_service.dart';

class BreakerBrakerGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, KeyboardEvents {
  final GameStateProvider gameState;

  // Game world
  late final World gameWorld;
  late final CameraComponent gameCamera;

  // Game components
  late TruckComponent playerTruck;
  late TrailerComponent trailer;
  late RoadComponent road;
  late TrafficSpawner trafficSpawner;
  late ScreenShake screenShake;
  late GameHUD hud;

  // Effects
  final particleEmitter = CollisionParticleEmitter();

  // Camera tracking
  Vector2 baseCameraPosition = Vector2.zero();

  // Input state
  bool _leftPressed = false;
  bool _rightPressed = false;
  bool _brakePressed = false;

  // Current game state
  bool _isPaused = false;
  bool get isPaused => _isPaused;

  BreakerBrakerGame({required this.gameState}) : super();

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize world
    gameWorld = World();

    // Set up camera to follow truck
    gameCamera = CameraComponent(world: gameWorld)
      ..viewfinder.anchor = Anchor.center;

    await add(gameWorld);
    await add(gameCamera);

    // Create road
    road = RoadComponent(
      position: Vector2(size.x / 2, 0),
    );
    await gameWorld.add(road);

    // Get current truck and trailer from game state
    final currentTruck = gameState.getCurrentTruck() ??
        TruckTemplates.getDefaultTruck();
    final currentTrailer = gameState.getCurrentTrailer() ??
        TrailerTemplates.getDefaultTrailer();

    // Create player truck (don't add yet)
    playerTruck = TruckComponent(
      truckModel: currentTruck,
      playerModel: gameState.player,
      position: Vector2(
        size.x / 2, // Center horizontally
        size.y * 0.75, // 75% down the screen
      ),
    );

    // Create trailer
    trailer = TrailerComponent(
      trailerModel: currentTrailer,
      truck: playerTruck,
    );

    // Add in order: trailer first (renders behind), then truck
    await gameWorld.add(trailer);
    await gameWorld.add(playerTruck);

    // Position camera to show the action
    baseCameraPosition = Vector2(size.x / 2, size.y / 2);
    gameCamera.viewfinder.position = baseCameraPosition;

    // Create screen shake effect
    screenShake = ScreenShake();
    await add(screenShake);

    // Create traffic spawner
    trafficSpawner = TrafficSpawner(
      screenWidth: size.x,
      playerSpeed: playerTruck.currentSpeed,
    );
    await gameWorld.add(trafficSpawner);

    // Create HUD (not part of world, overlays on top)
    hud = GameHUD(
      playerModel: gameState.player,
      truck: playerTruck,
    );
    await add(hud);

    debugPrint('BreakerBraker game initialized');
    debugPrint('Truck: ${currentTruck.name}');
    debugPrint('Career: ${gameState.player.getCareerStageTitle()}');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isPaused) return;

    // Update truck controls
    playerTruck.setControls(
      left: _leftPressed,
      right: _rightPressed,
      brake: _brakePressed,
    );

    // Update road scroll speed to match truck speed
    road.updateScrollSpeed(playerTruck.currentSpeed);

    // Apply screen shake to camera
    final shakeOffset = screenShake.getOffset();
    gameCamera.viewfinder.position = baseCameraPosition + shakeOffset;

    // TODO: Additional game logic
    // - ELD timer countdown
    // - Dispatcher calls
    // - Achievement checks
  }

  // === Input Handling ===

  @override
  void onTapDown(TapDownEvent event) {
    // Landscape layout: left side = left turn, right side = right turn
    final screenWidth = size.x;
    final tapX = event.localPosition.x;

    if (tapX < screenWidth / 3) {
      // Left third - steer left
      _leftPressed = true;
    } else if (tapX > screenWidth * 2 / 3) {
      // Right third - steer right
      _rightPressed = true;
    } else {
      // Middle third - brake or special action
      _brakePressed = true;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    _leftPressed = false;
    _rightPressed = false;
    _brakePressed = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _leftPressed = false;
    _rightPressed = false;
    _brakePressed = false;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // Desktop testing support
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        _leftPressed = true;
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        _rightPressed = true;
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _brakePressed = true;
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        _leftPressed = false;
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        _rightPressed = false;
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _brakePressed = false;
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  // === Game Control Methods ===

  /// Pause the game
  void pauseGame() {
    _isPaused = true;
    pauseEngine();
  }

  /// Resume the game
  void resumeGame() {
    _isPaused = false;
    resumeEngine();
  }

  /// Reset the game
  void resetGame() {
    // TODO: Reset truck position, clear obstacles, etc.
    _leftPressed = false;
    _rightPressed = false;
    _brakePressed = false;
  }

  /// Get current input state
  Map<String, bool> getInputState() {
    return {
      'left': _leftPressed,
      'right': _rightPressed,
      'brake': _brakePressed,
    };
  }

  /// Handle collision between truck and obstacle
  void handleCollision({
    required String obstacleType,
    required double impactForce,
    Vector2? collisionPosition,
  }) {
    // Use collision position or truck position
    final particlePosition = collisionPosition ?? playerTruck.position;
    // Apply damage based on impact
    final damageAmount = impactForce * 0.5; // Scale impact to damage
    // TODO: Apply to specific components based on collision angle

    // Award damage points
    int dpAward = 0;

    // Determine haptic intensity, screen shake, and DP based on obstacle type
    ImpactIntensity hapticIntensity;
    ShakeIntensity shakeIntensity;

    switch (obstacleType.toLowerCase()) {
      case 'car':
      case 'four-wheeler':
        dpAward = GameConfig.fourWheelerDP;
        hapticIntensity = ImpactIntensity.light;
        shakeIntensity = ShakeIntensity.light;
        HapticService.carCollision();
        screenShake.shake(intensity: shakeIntensity);
        particleEmitter.spawnExplosion(
          parent: gameWorld,
          position: particlePosition,
          collisionType: 'car',
          particleCount: 25,
        );
        gameState.recordFourWheelerDestroyed();
        break;

      case 'sign':
        dpAward = GameConfig.signDP;
        hapticIntensity = ImpactIntensity.light;
        shakeIntensity = ShakeIntensity.light;
        HapticService.obstacleCollision();
        screenShake.shake(intensity: shakeIntensity);
        particleEmitter.spawnExplosion(
          parent: gameWorld,
          position: particlePosition,
          collisionType: 'sign',
          particleCount: 15,
        );
        gameState.recordSignDestroyed();
        break;

      case 'barrier':
      case 'cone':
        dpAward = GameConfig.barrierDP;
        hapticIntensity = ImpactIntensity.medium;
        shakeIntensity = ShakeIntensity.medium;
        HapticService.obstacleCollision();
        screenShake.shake(intensity: shakeIntensity);
        particleEmitter.spawnExplosion(
          parent: gameWorld,
          position: particlePosition,
          collisionType: 'barrier',
          particleCount: 20,
        );
        break;

      case 'bridge':
        dpAward = GameConfig.baseDamagePointsPerHit * GameConfig.bridgeHitDPMultiplier;
        hapticIntensity = ImpactIntensity.extreme;
        shakeIntensity = ShakeIntensity.extreme;
        HapticService.bridgeHit();
        screenShake.shake(intensity: shakeIntensity);
        particleEmitter.spawnExplosion(
          parent: gameWorld,
          position: particlePosition,
          collisionType: 'bridge',
          particleCount: 50, // HUGE explosion!
        );
        gameState.recordBridgeHit();
        break;

      case 'lowboy-bridge':
        // MASSIVE DP for bridge damage with lowboy!
        dpAward = GameConfig.baseDamagePointsPerHit * GameConfig.lowboyBridgeHitDPMultiplier;
        hapticIntensity = ImpactIntensity.extreme;
        shakeIntensity = ShakeIntensity.extreme;
        HapticService.bridgeHit();
        screenShake.shake(intensity: shakeIntensity);
        particleEmitter.spawnExplosion(
          parent: gameWorld,
          position: particlePosition,
          collisionType: 'lowboy-bridge',
          particleCount: 60, // EVEN BIGGER!
        );
        gameState.recordBridgeHit();
        break;

      default:
        dpAward = GameConfig.baseDamagePointsPerHit;
        hapticIntensity = ImpactIntensity.medium;
        shakeIntensity = ShakeIntensity.medium;
        HapticService.impact(hapticIntensity);
        screenShake.shake(intensity: shakeIntensity);
        particleEmitter.spawnExplosion(
          parent: gameWorld,
          position: particlePosition,
          collisionType: 'default',
          particleCount: 20,
        );
    }

    // Award the DP
    awardDamagePoints(dpAward, reason: obstacleType);

    // Check if truck is totaled after this hit
    if (gameState.player.truckDamage.isTotaled) {
      HapticService.vehicleTotaled();
      screenShake.shake(intensity: ShakeIntensity.extreme, customDuration: 1.0);
      debugPrint('TRUCK TOTALED!');
      // TODO: Trigger totaled state, end run
    }

    debugPrint('Collision: $obstacleType, Force: $impactForce, DP: +$dpAward');
  }

  /// Award damage points
  void awardDamagePoints(int points, {String? reason}) {
    gameState.player.damagePoints += points;
    debugPrint('Awarded $points DP${reason != null ? ' for $reason' : ''}');
  }
}
