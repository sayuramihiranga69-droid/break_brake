/// Collision particle effects
/// Sparks, debris, smoke, and metal fragments
library;

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ParticleType {
  spark,      // Yellow/orange sparks (metal on metal)
  debris,     // Dark gray chunks (car parts)
  smoke,      // Gray/white smoke puffs
  glass,      // Light blue glass shards
}

class CollisionParticle extends PositionComponent {
  final ParticleType type;
  Vector2 velocity; // Non-final so we can apply gravity
  final double lifetime;
  final Color baseColor;

  double age = 0;
  double rotationSpeed;
  double currentRotation = 0;
  double particleSize; // Renamed to avoid conflict with PositionComponent.size

  CollisionParticle({
    required this.type,
    required Vector2 position,
    required this.velocity,
    required this.lifetime,
    required this.baseColor,
    required this.particleSize,
  })  : rotationSpeed = (Random().nextDouble() - 0.5) * 10,
        super(position: position, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);

    age += dt;

    // Remove particle after lifetime
    if (age >= lifetime) {
      removeFromParent();
      return;
    }

    // Update position with velocity
    position += velocity * dt;

    // Apply gravity for debris
    if (type == ParticleType.debris || type == ParticleType.glass) {
      velocity.y += 500 * dt; // Gravity
    }

    // Slow down over time (air resistance)
    velocity *= 0.98;

    // Rotate
    currentRotation += rotationSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = age / lifetime;
    final fade = 1.0 - progress;

    canvas.save();
    canvas.rotate(currentRotation);

    switch (type) {
      case ParticleType.spark:
        _renderSpark(canvas, fade);
        break;
      case ParticleType.debris:
        _renderDebris(canvas, fade);
        break;
      case ParticleType.smoke:
        _renderSmoke(canvas, fade);
        break;
      case ParticleType.glass:
        _renderGlass(canvas, fade);
        break;
    }

    canvas.restore();
  }

  void _renderSpark(Canvas canvas, double fade) {
    // Bright spark (starts bright, fades fast)
    final sparkPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          baseColor.withValues(alpha: fade),
          baseColor.withValues(alpha: fade * 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: particleSize));

    // Draw spark with trail
    canvas.drawCircle(Offset.zero, particleSize * fade, sparkPaint);

    // Spark tail (motion blur effect)
    final tailLength = velocity.length * 0.05;
    final tailDirection = -velocity.normalized();

    final tailPaint = Paint()
      ..color = baseColor.withValues(alpha: fade * 0.3)
      ..strokeWidth = particleSize * 0.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset.zero,
      Offset(tailDirection.x * tailLength, tailDirection.y * tailLength),
      tailPaint,
    );
  }

  void _renderDebris(Canvas canvas, double fade) {
    // Dark chunk of metal/car part
    final debrisPaint = Paint()
      ..color = baseColor.withValues(alpha: fade)
      ..style = PaintingStyle.fill;

    // Irregular shape (rectangle with random rotation)
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: particleSize,
      height: particleSize * 0.7,
    );

    canvas.drawRect(rect, debrisPaint);

    // Edge highlight
    final edgePaint = Paint()
      ..color = Colors.grey.shade600.withValues(alpha: fade * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRect(rect, edgePaint);
  }

  void _renderSmoke(Canvas canvas, double fade) {
    // Expanding smoke puff
    final smokeSize = particleSize * (1.0 + age * 2); // Grows over time

    final smokePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          baseColor.withValues(alpha: fade * 0.6),
          baseColor.withValues(alpha: fade * 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: smokeSize));

    canvas.drawCircle(Offset.zero, smokeSize, smokePaint);
  }

  void _renderGlass(Canvas canvas, double fade) {
    // Shiny glass shard
    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withValues(alpha: fade * 0.8),
          Colors.white.withValues(alpha: fade * 0.4),
          baseColor.withValues(alpha: fade * 0.6),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset.zero,
        width: particleSize,
        height: particleSize * 1.5,
      ));

    // Triangle shard shape
    final path = Path()
      ..moveTo(0, -particleSize)
      ..lineTo(particleSize * 0.5, particleSize * 0.5)
      ..lineTo(-particleSize * 0.5, particleSize * 0.5)
      ..close();

    canvas.drawPath(path, glassPaint);
  }
}

/// Particle emitter - spawns particles on collision
class CollisionParticleEmitter {
  final Random _random = Random();

  /// Spawn explosion of particles at collision point
  void spawnExplosion({
    required Component parent,
    required Vector2 position,
    required String collisionType,
    int particleCount = 20,
  }) {
    switch (collisionType.toLowerCase()) {
      case 'car':
      case 'four-wheeler':
        _spawnCarExplosion(parent, position, particleCount);
        break;
      case 'sign':
        _spawnSignExplosion(parent, position, particleCount);
        break;
      case 'barrier':
      case 'cone':
        _spawnBarrierExplosion(parent, position, particleCount);
        break;
      case 'bridge':
      case 'lowboy-bridge':
        _spawnBridgeExplosion(parent, position, particleCount * 3);
        break;
      default:
        _spawnGenericExplosion(parent, position, particleCount);
    }
  }

  void _spawnCarExplosion(Component parent, Vector2 position, int count) {
    // Metal debris, glass, and sparks
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 6.28;
      final speed = 100 + _random.nextDouble() * 200;

      final velocity = Vector2(
        cos(angle) * speed,
        sin(angle) * speed,
      );

      ParticleType type;
      Color color;
      double particleSize;

      if (i < count * 0.4) {
        // 40% sparks
        type = ParticleType.spark;
        color = Color.lerp(Colors.yellow, Colors.orange, _random.nextDouble())!;
        particleSize = 2 + _random.nextDouble() * 2;
      } else if (i < count * 0.7) {
        // 30% debris
        type = ParticleType.debris;
        color = Color.lerp(Colors.grey.shade800, Colors.grey.shade600, _random.nextDouble())!;
        particleSize = 3 + _random.nextDouble() * 4;
      } else {
        // 30% glass
        type = ParticleType.glass;
        color = Colors.lightBlue.withValues(alpha: 0.7);
        particleSize = 2 + _random.nextDouble() * 3;
      }

      parent.add(CollisionParticle(
        type: type,
        position: position.clone(),
        velocity: velocity,
        lifetime: 0.5 + _random.nextDouble() * 0.5,
        baseColor: color,
        particleSize: particleSize,
      ));
    }

    // Add some smoke
    for (int i = 0; i < 5; i++) {
      final angle = _random.nextDouble() * 6.28;
      final speed = 30 + _random.nextDouble() * 50;

      parent.add(CollisionParticle(
        type: ParticleType.smoke,
        position: position.clone(),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed - 50),
        lifetime: 1.0 + _random.nextDouble(),
        baseColor: Colors.grey.shade400,
        particleSize: 4 + _random.nextDouble() * 4,
      ));
    }
  }

  void _spawnSignExplosion(Component parent, Vector2 position, int count) {
    // Light debris flying everywhere
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 6.28;
      final speed = 150 + _random.nextDouble() * 250;

      parent.add(CollisionParticle(
        type: ParticleType.debris,
        position: position.clone(),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        lifetime: 0.4 + _random.nextDouble() * 0.4,
        baseColor: Color.lerp(Colors.red, Colors.white, _random.nextDouble())!,
        particleSize: 2 + _random.nextDouble() * 3,
      ));
    }
  }

  void _spawnBarrierExplosion(Component parent, Vector2 position, int count) {
    // Orange/yellow chunks
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 6.28;
      final speed = 120 + _random.nextDouble() * 180;

      parent.add(CollisionParticle(
        type: ParticleType.debris,
        position: position.clone(),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        lifetime: 0.5 + _random.nextDouble() * 0.5,
        baseColor: Colors.orange,
        particleSize: 3 + _random.nextDouble() * 4,
      ));
    }
  }

  void _spawnBridgeExplosion(Component parent, Vector2 position, int count) {
    // MASSIVE explosion - tons of sparks, debris, and smoke
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 6.28;
      final speed = 200 + _random.nextDouble() * 400;

      ParticleType type;
      Color color;
      double particleSize;

      if (i < count * 0.5) {
        // 50% sparks (TONS of sparks!)
        type = ParticleType.spark;
        color = Color.lerp(Colors.yellow, Colors.red, _random.nextDouble())!;
        particleSize = 3 + _random.nextDouble() * 4;
      } else {
        // 50% debris
        type = ParticleType.debris;
        color = Colors.grey.shade700;
        particleSize = 4 + _random.nextDouble() * 6;
      }

      parent.add(CollisionParticle(
        type: type,
        position: position.clone(),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        lifetime: 0.8 + _random.nextDouble() * 0.7,
        baseColor: color,
        particleSize: particleSize,
      ));
    }

    // Huge smoke cloud
    for (int i = 0; i < 15; i++) {
      final angle = _random.nextDouble() * 6.28;
      final speed = 40 + _random.nextDouble() * 80;

      parent.add(CollisionParticle(
        type: ParticleType.smoke,
        position: position.clone(),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed - 60),
        lifetime: 1.5 + _random.nextDouble() * 1.0,
        baseColor: Colors.grey.shade500,
        particleSize: 8 + _random.nextDouble() * 8,
      ));
    }
  }

  void _spawnGenericExplosion(Component parent, Vector2 position, int count) {
    _spawnCarExplosion(parent, position, count);
  }
}
