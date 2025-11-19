/// Player truck component
/// Handles rendering, physics, and controls
library;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../models/truck_model.dart';
import '../../models/player_model.dart';
import '../../config/game_config.dart';
import '../obstacles/car_component.dart';
import '../../game/breaker_braker_game.dart';

class TruckComponent extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  final TruckModel truckModel;
  final PlayerModel playerModel;

  // Physics state
  double currentSpeed = 0.0;
  double targetSpeed = 0.0;
  double currentRotation = 0.0;
  double lateralVelocity = 0.0; // Side-to-side momentum
  double rotationVelocity = 0.0; // Angular momentum

  // Control inputs
  bool steerLeft = false;
  bool steerRight = false;
  bool braking = false;

  // Physics constants
  static const double maxRotation = 0.6;
  static const double rotationAcceleration = 3.0;
  static const double rotationDamping = 0.88;
  static const double lateralDamping = 0.92;
  static const double driftFactor = 60.0;

  // Visual dimensions - now bigger and beefier!
  static const double truckWidth = 50.0;
  static const double truckHeight = 120.0;

  // Trailer connection
  Vector2? trailerPosition;

  TruckComponent({
    required this.truckModel,
    required this.playerModel,
    Vector2? position,
  }) : super(
          position: position ?? Vector2.zero(),
          size: Vector2(truckWidth, truckHeight),
          anchor: Anchor.bottomCenter, // Pivot from rear axle!
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set initial speed (auto-accelerate)
    targetSpeed = truckModel.baseSpeed;

    // Add collision hitbox
    add(RectangleHitbox(
      size: size,
      position: Vector2.zero(),
      anchor: Anchor.bottomCenter,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // === SPEED PHYSICS ===
    // Auto-accelerate unless braking
    if (!braking) {
      targetSpeed = _getEffectiveMaxSpeed();
    } else {
      // Progressive braking - harder brake = slower
      targetSpeed = truckModel.baseSpeed * 0.2;
    }

    // Smooth acceleration with easing curve
    final speedDiff = targetSpeed - currentSpeed;
    if (speedDiff.abs() > 1.0) {
      final accelRate = speedDiff > 0
          ? truckModel.acceleration
          : GameConfig.truckDeceleration * 1.5;
      currentSpeed += speedDiff.sign * accelRate * dt;
    }

    // Apply damage speed penalty
    final speedPenalty = playerModel.truckDamage.speedPenalty;
    currentSpeed *= (1.0 - speedPenalty);

    // Clamp speed
    currentSpeed = currentSpeed.clamp(0, _getEffectiveMaxSpeed());

    // === STEERING PHYSICS (Momentum-based) ===
    final handlingPenalty = playerModel.truckDamage.handlingPenalty;
    final effectiveHandling = truckModel.getEffectiveHandling() * (1.0 - handlingPenalty);

    // Apply steering input to rotation velocity (not direct rotation)
    if (steerLeft && !steerRight) {
      rotationVelocity -= rotationAcceleration * effectiveHandling * dt;
    } else if (steerRight && !steerLeft) {
      rotationVelocity += rotationAcceleration * effectiveHandling * dt;
    }

    // Apply damping (auto-straighten)
    rotationVelocity *= rotationDamping;

    // Clamp rotation velocity
    rotationVelocity = rotationVelocity.clamp(-maxRotation, maxRotation);

    // Apply rotation velocity to actual rotation
    currentRotation += rotationVelocity * dt;
    currentRotation = currentRotation.clamp(-maxRotation, maxRotation);

    // Set visual angle
    angle = currentRotation;

    // === LATERAL MOVEMENT (Drift Physics) ===
    // When turning, truck drifts sideways (arcade feel!)
    lateralVelocity += currentRotation * driftFactor * dt;

    // Apply lateral damping
    lateralVelocity *= lateralDamping;

    // Apply lateral movement
    position.x += lateralVelocity * dt;

    // === BOUNDS CHECKING ===
    final gameWidth = game.size.x;
    final minX = truckWidth / 2;
    final maxX = gameWidth - truckWidth / 2;

    // Bounce off edges (arcade style!)
    if (position.x < minX) {
      position.x = minX;
      lateralVelocity = -lateralVelocity * 0.5; // Bounce back
      rotationVelocity *= 0.7; // Reduce rotation
    } else if (position.x > maxX) {
      position.x = maxX;
      lateralVelocity = -lateralVelocity * 0.5; // Bounce back
      rotationVelocity *= 0.7; // Reduce rotation
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // PLACEHOLDER RENDERING - Replace with actual sprites later
    _renderPlaceholder(canvas);
  }

  void _renderPlaceholder(Canvas canvas) {
    final truckColor = _getTruckColor();

    // Render based on manufacturer type for distinct looks
    switch (truckModel.type) {
      case TruckType.kenworthW900:
        _renderClassicLongHood(canvas, truckColor, isKenworth: true);
        break;
      case TruckType.peterbilt379:
        _renderClassicLongHood(canvas, truckColor, isKenworth: false);
        break;
      case TruckType.international9900i:
        _renderInternationalLonestar(canvas, truckColor);
        break;
      case TruckType.volvoVNL:
        _renderVolvoAero(canvas, truckColor);
        break;
      case TruckType.freightlinerCascadia:
        _renderFreightlinerAero(canvas, truckColor);
        break;
      default:
        _renderClassicLongHood(canvas, truckColor, isKenworth: true);
    }
  }

  /// Render classic long-hood truck (Kenworth W900, Peterbilt 379)
  void _renderClassicLongHood(Canvas canvas, Color truckColor, {required bool isKenworth}) {
    // === MASSIVE SHADOW ===
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawOval(
      Rect.fromLTWH(-size.x / 2, size.y / 2 - 10, size.x, 16),
      shadowPaint,
    );

    // === SLEEPER (large, boxy) ===
    final sleeperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-size.x / 2, -size.y * 0.2, size.x, size.y * 0.30),
      const Radius.circular(4),
    );

    // Sleeper with gradient
    final sleeperPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          truckColor.withValues(alpha: 0.85),
          truckColor,
          truckColor.withValues(alpha: 0.9),
        ],
      ).createShader(sleeperRect.outerRect);
    canvas.drawRRect(sleeperRect, sleeperPaint);

    // Sleeper window
    final sleeperWindowPaint = Paint()
      ..color = Colors.lightBlue.withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.x / 2 + 5, -size.y * 0.15, size.x - 10, 12),
        const Radius.circular(2),
      ),
      sleeperWindowPaint,
    );

    // === LONG HOOD (classic extended) ===
    final hoodPath = Path()
      ..moveTo(-size.x / 2, -size.y * 0.2)
      ..lineTo(-size.x / 2, -size.y * 0.45) // Long hood!
      ..lineTo(-size.x / 2 + 4, -size.y * 0.5)
      ..lineTo(size.x / 2 - 4, -size.y * 0.5)
      ..lineTo(size.x / 2, -size.y * 0.45)
      ..lineTo(size.x / 2, -size.y * 0.2)
      ..close();

    final hoodPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          truckColor.withValues(alpha: 0.9),
          truckColor,
          truckColor.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(-size.x / 2, -size.y * 0.5, size.x, size.y * 0.3));
    canvas.drawPath(hoodPath, hoodPaint);

    // Hood center detail (raised power dome)
    final powerDomePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          truckColor.withValues(alpha: 0.7),
          truckColor,
          truckColor.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromLTWH(-6, -size.y * 0.45, 12, size.y * 0.2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-6, -size.y * 0.45, 12, size.y * 0.2),
        const Radius.circular(2),
      ),
      powerDomePaint,
    );

    // === WINDSHIELD (large wraparound) ===
    final windshieldPath = Path()
      ..moveTo(-size.x / 2 + 4, -size.y * 0.2 + 2)
      ..lineTo(-size.x / 2 + 6, -size.y * 0.2 + 18)
      ..lineTo(size.x / 2 - 6, -size.y * 0.2 + 18)
      ..lineTo(size.x / 2 - 4, -size.y * 0.2 + 2)
      ..close();

    final windshieldPaint = Paint()
      ..color = _getWindshieldColor();
    canvas.drawPath(windshieldPath, windshieldPaint);

    // Windshield glare
    final windshieldGlare = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(-size.x / 2 + 4, -size.y * 0.2 + 2, size.x - 8, 16));
    canvas.drawPath(windshieldPath, windshieldGlare);

    // === MASSIVE CHROME BUMPER ===
    final bumperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-size.x / 2 + 2, -size.y * 0.5, size.x - 4, 8),
      const Radius.circular(3),
    );

    final bumperPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          GameColors.chromeShine,
          Colors.grey.shade300,
          Colors.grey.shade500,
        ],
      ).createShader(bumperRect.outerRect);
    canvas.drawRRect(bumperRect, bumperPaint);

    // Bumper highlight (super shiny chrome)
    final bumperHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(-size.x / 2 + 2, -size.y * 0.5, size.x / 2, 4));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.x / 2 + 2, -size.y * 0.5, size.x / 2, 4),
        const Radius.circular(3),
      ),
      bumperHighlight,
    );

    // === PROMINENT GRILLE (manufacturer-specific) ===
    _renderGrille(canvas);

    // === BRIGHT HEADLIGHTS ===
    final headlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.shade100,
          Colors.yellow.shade300,
          Colors.yellow.shade700,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 5));

    // Main headlights (larger)
    canvas.drawCircle(Offset(-size.x / 2 + 8, -size.y * 0.48), 5, headlightPaint);
    canvas.drawCircle(Offset(size.x / 2 - 8, -size.y * 0.48), 5, headlightPaint);

    // Headlight chrome rings
    final headlightRingPaint = Paint()
      ..color = GameColors.chromeShine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(-size.x / 2 + 8, -size.y * 0.48), 6, headlightRingPaint);
    canvas.drawCircle(Offset(size.x / 2 - 8, -size.y * 0.48), 6, headlightRingPaint);

    // === TALL CHROME EXHAUST STACKS ===
    final stackHeight = size.y * 0.35;
    final stackPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.grey.shade500,
          GameColors.chromeShine,
          Colors.white,
          GameColors.chromeShine,
          Colors.grey.shade400,
        ],
      ).createShader(Rect.fromLTWH(0, 0, 5, stackHeight));

    // Left stack (TALL and CHROME)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.x / 2 - 3, -size.y * 0.1, 5, stackHeight),
        const Radius.circular(2.5),
      ),
      stackPaint,
    );

    // Right stack
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x / 2 - 2, -size.y * 0.1, 5, stackHeight),
        const Radius.circular(2.5),
      ),
      stackPaint,
    );

    // Stack tops (shiny chrome caps)
    final stackTopPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          GameColors.chromeShine,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 3));
    canvas.drawCircle(Offset(-size.x / 2 - 0.5, -size.y * 0.1), 3, stackTopPaint);
    canvas.drawCircle(Offset(size.x / 2 + 0.5, -size.y * 0.1), 3, stackTopPaint);

    // === LARGE WEST COAST MIRRORS ===
    final mirrorArmPaint = Paint()..color = Colors.grey.shade700;
    final mirrorGlassPaint = Paint()..color = Colors.grey.shade800;

    // Left mirror assembly
    canvas.drawRect(
      Rect.fromLTWH(-size.x / 2 - 2, -size.y * 0.15, 2, 8),
      mirrorArmPaint,
    ); // Mirror arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.x / 2 - 8, -size.y * 0.15, 5, 8),
        const Radius.circular(1),
      ),
      mirrorGlassPaint,
    ); // Mirror glass

    // Right mirror assembly
    canvas.drawRect(
      Rect.fromLTWH(size.x / 2, -size.y * 0.15, 2, 8),
      mirrorArmPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x / 2 + 3, -size.y * 0.15, 5, 8),
        const Radius.circular(1),
      ),
      mirrorGlassPaint,
    );

    // === CHROME WHEELS (bigger and beefier) ===
    _renderChromeWheel(canvas, Offset(-size.x / 2 + 9, -size.y * 0.35)); // Front left
    _renderChromeWheel(canvas, Offset(size.x / 2 - 9, -size.y * 0.35)); // Front right
    _renderChromeWheel(canvas, Offset(-size.x / 2 + 9, size.y * 0.35)); // Rear left front
    _renderChromeWheel(canvas, Offset(-size.x / 2 + 9, size.y * 0.45)); // Rear left back
    _renderChromeWheel(canvas, Offset(size.x / 2 - 9, size.y * 0.35)); // Rear right front
    _renderChromeWheel(canvas, Offset(size.x / 2 - 9, size.y * 0.45)); // Rear right back

    // === DAMAGE OVERLAY ===
    if (playerModel.truckDamage.totalDamage > 0) {
      _renderDamageOverlay(canvas);
    }
  }

  /// Render International Lonestar (aggressive angular design)
  void _renderInternationalLonestar(Canvas canvas, Color truckColor) {
    // TODO: Implement Lonestar-specific rendering
    // For now, use classic long hood as fallback
    _renderClassicLongHood(canvas, truckColor, isKenworth: false);
  }

  /// Render Volvo VNL (modern aerodynamic)
  void _renderVolvoAero(Canvas canvas, Color truckColor) {
    // TODO: Implement Volvo-specific rendering with short nose and huge windshield
    // For now, use classic long hood as fallback
    _renderClassicLongHood(canvas, truckColor, isKenworth: true);
  }

  /// Render Freightliner Cascadia (utilitarian aero)
  void _renderFreightlinerAero(Canvas canvas, Color truckColor) {
    // TODO: Implement Cascadia-specific rendering
    // For now, use classic long hood as fallback
    _renderClassicLongHood(canvas, truckColor, isKenworth: false);
  }

  /// Render enhanced chrome wheel
  void _renderChromeWheel(Canvas canvas, Offset position) {
    // Outer tire (black with sidewall detail)
    final tirePaint = Paint()
      ..color = Colors.grey.shade900;
    canvas.drawCircle(position, 8, tirePaint);

    // Tire sidewall highlight
    final sidewallPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(position, 7, sidewallPaint);

    // Chrome rim (shiny!)
    final rimPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          GameColors.chromeShine,
          Colors.grey.shade400,
        ],
      ).createShader(Rect.fromCircle(center: position, radius: 6));
    canvas.drawCircle(position, 6, rimPaint);

    // Rim spokes (detailed)
    final spokePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double angle = 0; angle < 6.28; angle += 1.047) { // 6 spokes
      canvas.drawLine(
        position + Offset(2 * cos(angle), 2 * sin(angle)),
        position + Offset(5 * cos(angle), 5 * sin(angle)),
        spokePaint,
      );
    }

    // Center chrome cap
    final capPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          GameColors.chromeShine,
        ],
      ).createShader(Rect.fromCircle(center: position, radius: 2));
    canvas.drawCircle(position, 2, capPaint);
  }

  /// Render damage overlay
  void _renderDamageOverlay(Canvas canvas) {
    final damagePaint = Paint()
      ..color = GameColors.damageRed.withValues(alpha: playerModel.truckDamage.totalDamage * 0.002)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y),
        const Radius.circular(4),
      ),
      damagePaint,
    );
  }


  void _renderGrille(Canvas canvas) {
    final grillePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    final grilleRect = Rect.fromLTWH(-size.x / 2 + 6, -size.y / 2 + 5, size.x - 12, 12);

    canvas.drawRRect(
      RRect.fromRectAndRadius(grilleRect, const Radius.circular(1)),
      grillePaint,
    );

    final grilleBarPaint = Paint()
      ..color = GameColors.chromeShine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Different grille patterns by manufacturer
    switch (truckModel.type) {
      // PETERBILT - Vertical bars (iconic Pete style)
      case TruckType.peterbilt379:
      case TruckType.peterbilt362:
        for (double x = -size.x / 2 + 8; x < size.x / 2 - 8; x += 3) {
          canvas.drawLine(
            Offset(x, -size.y / 2 + 6),
            Offset(x, -size.y / 2 + 16),
            grilleBarPaint,
          );
        }
        break;

      // KENWORTH - Cross-hatch pattern
      case TruckType.kenworthW900:
      case TruckType.kenworthK100:
      case TruckType.kenworthT680:
        // Horizontal bars
        for (double y = -size.y / 2 + 7; y < -size.y / 2 + 16; y += 2) {
          canvas.drawLine(
            Offset(-size.x / 2 + 8, y),
            Offset(size.x / 2 - 8, y),
            grilleBarPaint,
          );
        }
        // Vertical bars
        for (double x = -size.x / 2 + 10; x < size.x / 2 - 10; x += 4) {
          canvas.drawLine(
            Offset(x, -size.y / 2 + 6),
            Offset(x, -size.y / 2 + 16),
            grilleBarPaint,
          );
        }
        break;

      // FREIGHTLINER - Horizontal bars (modern aero style)
      case TruckType.freightlinerCascadia:
      case TruckType.freightlinerClassicXL:
      case TruckType.freightlinerFLB:
        for (double y = -size.y / 2 + 7; y < -size.y / 2 + 16; y += 3) {
          canvas.drawLine(
            Offset(-size.x / 2 + 8, y),
            Offset(size.x / 2 - 8, y),
            grilleBarPaint,
          );
        }
        break;

      // INTERNATIONAL - Diamond/mesh pattern
      case TruckType.international9900i:
        // Diamond pattern
        for (double y = -size.y / 2 + 7; y < -size.y / 2 + 16; y += 3) {
          for (double x = -size.x / 2 + 8; x < size.x / 2 - 8; x += 4) {
            final offset = (y / 3).floor() % 2 == 0 ? 0.0 : 2.0;
            canvas.drawCircle(Offset(x + offset, y), 0.5, grilleBarPaint);
          }
        }
        break;

      // VOLVO - Horizontal with center split
      case TruckType.volvoVNL:
        // Left side
        for (double y = -size.y / 2 + 7; y < -size.y / 2 + 16; y += 2) {
          canvas.drawLine(
            Offset(-size.x / 2 + 8, y),
            Offset(-2, y),
            grilleBarPaint,
          );
        }
        // Right side
        for (double y = -size.y / 2 + 7; y < -size.y / 2 + 16; y += 2) {
          canvas.drawLine(
            Offset(2, y),
            Offset(size.x / 2 - 8, y),
            grilleBarPaint,
          );
        }
        // Center divider
        canvas.drawLine(
          Offset(0, -size.y / 2 + 6),
          Offset(0, -size.y / 2 + 16),
          Paint()
            ..color = GameColors.chromeShine
            ..strokeWidth = 2,
        );
        break;
    }
  }

  Color _getTruckColor() {
    // Color based on career stage
    switch (playerModel.careerStage) {
      case CareerStage.companyDriver:
        return Colors.white; // Plain white company truck
      case CareerStage.leaseOperator:
        return GameColors.leaseOperator;
      case CareerStage.ownerOperator:
        return GameColors.ownerOperator;
    }
  }

  Color _getWindshieldColor() {
    final windshieldDamage =
        playerModel.truckDamage.components['windshield']?.damageLevel ?? 0.0;

    if (windshieldDamage > 75) {
      return Colors.red.withOpacity(0.3); // Shattered
    } else if (windshieldDamage > 25) {
      return Colors.lightBlue.withOpacity(0.5); // Cracked
    } else {
      return Colors.lightBlue.withOpacity(0.7); // Clean
    }
  }

  double _getEffectiveMaxSpeed() {
    return truckModel.getEffectiveMaxSpeed(playerModel.careerStage);
  }

  /// Set control inputs from game input system
  void setControls({
    required bool left,
    required bool right,
    required bool brake,
  }) {
    steerLeft = left;
    steerRight = right;
    braking = brake;
  }

  /// Get current speed in mph for display
  int getSpeedMph() {
    // Convert pixels/second to approximate mph
    return (currentSpeed * 0.3).round();
  }

  /// Apply damage from collision
  void applyCollisionDamage(double impactForce, {String? component}) {
    // Damage is already tracked in playerModel.truckDamage
    // This is just for any truck-specific reactions
    // (visual effects, sound triggers, etc. will go here)
  }

  /// Check if truck is totaled
  bool get isTotaled => playerModel.truckDamage.isTotaled;

  /// Handle collision with obstacles
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Check if we hit a car
    if (other is CarComponent && !other.isDestroyed) {
      // Calculate impact force based on speed
      final impactForce = currentSpeed * 0.5;

      // Destroy the car
      other.destroy();

      // Get the game instance and trigger collision handler
      if (game is BreakerBrakerGame) {
        final brakerGame = game as BreakerBrakerGame;
        brakerGame.handleCollision(
          obstacleType: 'four-wheeler',
          impactForce: impactForce,
        );
      }
    }
  }
}
