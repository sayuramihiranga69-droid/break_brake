/// Four-wheeler traffic car component
/// AI-controlled vehicles that can be destroyed for DP
library;

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

enum CarType {
  sedan,
  suv,
  sports,
  minivan,
}

class CarComponent extends PositionComponent with CollisionCallbacks {
  final CarType type;
  final int lane; // 0 = left, 1 = center, 2 = right
  final double baseSpeed;

  bool isDestroyed = false;
  double destructionTimer = 0;
  static const double destructionDuration = 0.5; // How long to show wreckage

  // Visual properties
  late Color carColor;
  late double carWidth;
  late double carLength;

  CarComponent({
    required this.type,
    required this.lane,
    required this.baseSpeed,
    required Vector2 position,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set size based on car type
    switch (type) {
      case CarType.sedan:
        carWidth = 28;
        carLength = 50;
        carColor = _randomSedan();
        break;
      case CarType.suv:
        carWidth = 32;
        carLength = 55;
        carColor = _randomSUV();
        break;
      case CarType.sports:
        carWidth = 26;
        carLength = 45;
        carColor = _randomSports();
        break;
      case CarType.minivan:
        carWidth = 30;
        carLength = 52;
        carColor = _randomMinivan();
        break;
    }

    size = Vector2(carWidth, carLength);

    // Add collision hitbox
    add(RectangleHitbox(
      size: size,
      position: Vector2.zero(),
      anchor: Anchor.center,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDestroyed) {
      destructionTimer += dt;

      // Remove after destruction duration
      if (destructionTimer >= destructionDuration) {
        removeFromParent();
      }
      return;
    }

    // Move car forward (down screen)
    position.y += baseSpeed * dt;

    // Remove if off bottom of screen
    if (position.y > 1000) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isDestroyed) {
      _renderWreckage(canvas);
    } else {
      _renderCar(canvas);
    }
  }

  void _renderCar(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(2, 2),
          width: carWidth,
          height: carLength,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Main body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: carWidth,
        height: carLength,
      ),
      const Radius.circular(4),
    );

    // Body gradient
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        carColor.withOpacity(0.9),
        carColor,
        carColor.withOpacity(0.7),
      ],
    ).createShader(bodyRect.outerRect);

    canvas.drawRRect(bodyRect, paint);

    // Windshield
    final windshieldPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.lightBlue.withOpacity(0.3),
          Colors.lightBlue.withOpacity(0.5),
        ],
      ).createShader(Rect.fromLTWH(-carWidth * 0.3, -carLength * 0.3, carWidth * 0.6, carLength * 0.2));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-carWidth * 0.3, -carLength * 0.3, carWidth * 0.6, carLength * 0.2),
        const Radius.circular(2),
      ),
      windshieldPaint,
    );

    // Rear window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-carWidth * 0.3, carLength * 0.15, carWidth * 0.6, carLength * 0.15),
        const Radius.circular(2),
      ),
      windshieldPaint,
    );

    // Headlights
    final headlightPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.8);

    canvas.drawCircle(Offset(-carWidth * 0.3, -carLength * 0.45), 3, headlightPaint);
    canvas.drawCircle(Offset(carWidth * 0.3, -carLength * 0.45), 3, headlightPaint);

    // Tail lights
    final taillightPaint = Paint()
      ..color = Colors.red.withOpacity(0.6);

    canvas.drawCircle(Offset(-carWidth * 0.35, carLength * 0.45), 2.5, taillightPaint);
    canvas.drawCircle(Offset(carWidth * 0.35, carLength * 0.45), 2.5, taillightPaint);

    // Side mirrors
    final mirrorPaint = Paint()..color = carColor.withOpacity(0.8);
    canvas.drawCircle(Offset(-carWidth * 0.5, 0), 3, mirrorPaint);
    canvas.drawCircle(Offset(carWidth * 0.5, 0), 3, mirrorPaint);
  }

  void _renderWreckage(Canvas canvas) {
    final progress = destructionTimer / destructionDuration;
    final paint = Paint()..style = PaintingStyle.fill;

    // Fade out and flatten
    final opacity = 1.0 - progress;
    final wreckageWidth = carWidth * (1.0 + progress * 0.5); // Spread out
    final wreckageLength = carLength * (1.0 - progress * 0.3); // Flatten

    // Draw flattened, smoking wreckage
    paint.color = carColor.withOpacity(opacity * 0.5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: wreckageWidth,
          height: wreckageLength,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Scorch marks
    paint.color = Colors.black.withOpacity(opacity * 0.3);
    canvas.drawCircle(Offset.zero, wreckageWidth * 0.6, paint);
  }

  /// Destroy this car
  void destroy() {
    if (isDestroyed) return;
    isDestroyed = true;
    destructionTimer = 0;
  }

  // Color randomizers for variety
  Color _randomSedan() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.grey,
      Colors.white,
      Colors.black,
      Colors.green,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  Color _randomSUV() {
    final colors = [
      Colors.grey.shade700,
      Colors.blue.shade800,
      Colors.black,
      Colors.white,
      Colors.brown,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  Color _randomSports() {
    final colors = [
      Colors.red,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.blue,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  Color _randomMinivan() {
    final colors = [
      Colors.grey,
      Colors.blue.shade300,
      Colors.brown,
      Colors.white,
      Colors.green.shade700,
    ];
    return colors[Random().nextInt(colors.length)];
  }
}
