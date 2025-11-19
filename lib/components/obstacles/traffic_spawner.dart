/// Traffic spawner - generates four-wheelers for destruction
library;

import 'dart:math';
import 'package:flame/components.dart';

import 'car_component.dart';

class TrafficSpawner extends Component with HasGameReference {
  final double screenWidth;
  final double playerSpeed;

  // Spawn timing
  double spawnTimer = 0;
  double spawnInterval = 1.5; // Spawn every 1.5 seconds
  final Random _random = Random();

  // Lane positions (based on road component)
  static const double roadCenterX = 400; // Half of 800px default width
  static const double laneWidth = 80;

  late final List<double> lanePositions;

  TrafficSpawner({
    required this.screenWidth,
    required this.playerSpeed,
  }) {
    // Calculate lane center positions
    // Left, Center, Right lanes
    lanePositions = [
      roadCenterX - laneWidth, // Left lane
      roadCenterX,              // Center lane
      roadCenterX + laneWidth,  // Right lane
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);

    spawnTimer += dt;

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      _spawnCar();

      // Vary spawn rate based on speed (more chaos at higher speeds)
      spawnInterval = 1.0 + _random.nextDouble() * 1.5;

      // Faster spawning at higher speeds
      if (playerSpeed > 300) {
        spawnInterval *= 0.7;
      }
    }
  }

  void _spawnCar() {
    // Choose random lane
    final lane = _random.nextInt(3);

    // Choose random car type
    final carTypes = CarType.values;
    final carType = carTypes[_random.nextInt(carTypes.length)];

    // Determine car speed (relative to player)
    // Some cars slower, some faster for variety
    final speedVariation = _random.nextDouble() * 100 - 50; // -50 to +50
    final carSpeed = (playerSpeed * 0.7) + speedVariation;

    // Spawn position (above screen, will scroll down)
    final spawnX = lanePositions[lane];
    final spawnY = -100.0; // Above screen

    final car = CarComponent(
      type: carType,
      lane: lane,
      baseSpeed: carSpeed,
      position: Vector2(spawnX, spawnY),
    );

    parent?.add(car);
  }

  /// Update player speed for dynamic spawn rate
  void updatePlayerSpeed(double speed) {
    // This would be called from the main game
    // We'll handle this in the game class
  }
}
