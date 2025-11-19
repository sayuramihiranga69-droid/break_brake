/// Trailer component that follows the truck
/// Includes sway physics for arcade feel
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../models/trailer_model.dart';
import '../../config/game_config.dart';
import 'truck_component.dart';

class TrailerComponent extends PositionComponent with HasGameReference {
  final TrailerModel trailerModel;
  final TruckComponent truck;

  // Physics state
  double trailerAngle = 0.0;
  double angleVelocity = 0.0;

  // Visual dimensions
  static const double trailerWidth = 38.0;
  static const double trailerLength = 140.0; // Longer than truck for 53' trailer

  // Connection point offset from truck center
  static const double hitchOffset = 45.0;

  // Sway physics
  static const double swayStiffness = 0.15; // How quickly trailer follows truck
  static const double swayDamping = 0.85; // Reduces oscillation
  static const double maxSwayAngle = 0.8; // Maximum jackknife angle

  TrailerComponent({
    required this.trailerModel,
    required this.truck,
  }) : super(
          size: Vector2(trailerWidth, trailerLength),
          anchor: Anchor.topCenter, // Pivot at hitch point
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Calculate hitch position (back of truck)
    final hitchPosition = truck.position +
        Vector2(0, TruckComponent.truckHeight / 2);

    // Calculate desired trailer angle (points toward hitch)
    final trailerFront = position;
    final angleToHitch = (hitchPosition - trailerFront).angleToSigned(Vector2(0, -1));

    // Apply spring physics to trailer angle
    final angleDiff = _normalizeAngle(angleToHitch - trailerAngle);
    angleVelocity += angleDiff * swayStiffness;
    angleVelocity *= swayDamping;

    // Clamp angle velocity
    angleVelocity = angleVelocity.clamp(-0.5, 0.5);

    // Apply velocity to angle
    trailerAngle += angleVelocity * dt * 60; // 60 for frame-rate independence
    trailerAngle = trailerAngle.clamp(-maxSwayAngle, maxSwayAngle);

    // Set visual angle
    angle = trailerAngle;

    // Position trailer so front (hitch) connects to truck back
    final trailerFrontOffset = Vector2(0, 0); // Hitch is at anchor (topCenter)
    position = hitchPosition - trailerFrontOffset;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render based on trailer type
    _renderTrailer(canvas);
  }

  void _renderTrailer(Canvas canvas) {
    switch (trailerModel.type) {
      case TrailerType.dryVan:
        _renderDryVan(canvas);
        break;
      case TrailerType.reefer:
        _renderReefer(canvas);
        break;
      case TrailerType.flatbed:
        _renderFlatbed(canvas);
        break;
      case TrailerType.tanker:
        _renderTanker(canvas);
        break;
      case TrailerType.lowboy:
        _renderLowboy(canvas);
        break;
      default:
        _renderDryVan(canvas); // Default
    }
  }

  void _renderDryVan(Canvas canvas) {
    // Main box
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      -size.x / 2,
      0,
      size.x,
      size.y,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      paint,
    );

    // Top section (slightly darker)
    final topPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    final topRect = Rect.fromLTWH(
      -size.x / 2,
      0,
      size.x,
      10,
    );

    canvas.drawRect(topRect, topPaint);

    // Wheels (simple circles)
    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Rear wheels (tandem)
    canvas.drawCircle(Offset(-size.x / 2 + 6, size.y - 15), 5, wheelPaint);
    canvas.drawCircle(Offset(size.x / 2 - 6, size.y - 15), 5, wheelPaint);
    canvas.drawCircle(Offset(-size.x / 2 + 6, size.y - 25), 5, wheelPaint);
    canvas.drawCircle(Offset(size.x / 2 - 6, size.y - 25), 5, wheelPaint);

    // Door seams
    final seamPaint = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, size.y * 0.2),
      Offset(0, size.y),
      seamPaint,
    );
  }

  void _renderReefer(Canvas canvas) {
    // Similar to dry van but with reefer unit on front
    _renderDryVan(canvas);

    // Reefer unit
    final reeferPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;

    final reeferRect = Rect.fromLTWH(
      -size.x / 2 + 4,
      -8,
      size.x - 8,
      12,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(reeferRect, const Radius.circular(2)),
      reeferPaint,
    );
  }

  void _renderFlatbed(Canvas canvas) {
    // Deck
    final deckPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    final deckRect = Rect.fromLTWH(
      -size.x / 2,
      size.y * 0.3,
      size.x,
      8,
    );

    canvas.drawRect(deckRect, deckPaint);

    // Side rails
    final railPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(-size.x / 2, size.y * 0.3),
      Offset(-size.x / 2, size.y),
      railPaint,
    );

    canvas.drawLine(
      Offset(size.x / 2, size.y * 0.3),
      Offset(size.x / 2, size.y),
      railPaint,
    );

    // Wheels
    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(-size.x / 2 + 6, size.y - 10), 5, wheelPaint);
    canvas.drawCircle(Offset(size.x / 2 - 6, size.y - 10), 5, wheelPaint);
  }

  void _renderTanker(Canvas canvas) {
    // Tank body
    final tankPaint = Paint()
      ..color = GameColors.chromeShine
      ..style = PaintingStyle.fill;

    // Elliptical tank
    final tankRect = Rect.fromLTWH(
      -size.x / 2 + 4,
      10,
      size.x - 8,
      size.y - 30,
    );

    canvas.drawOval(tankRect, tankPaint);

    // Tank segments
    final segmentPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (double y = 20; y < size.y - 20; y += 20) {
      canvas.drawLine(
        Offset(-size.x / 2 + 4, y),
        Offset(size.x / 2 - 4, y),
        segmentPaint,
      );
    }

    // Wheels
    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(-size.x / 2 + 6, size.y - 10), 5, wheelPaint);
    canvas.drawCircle(Offset(size.x / 2 - 6, size.y - 10), 5, wheelPaint);
  }

  void _renderLowboy(Canvas canvas) {
    // Low deck (lowboy sits lower)
    final deckPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    final deckRect = Rect.fromLTWH(
      -size.x / 2,
      size.y * 0.5,
      size.x,
      10,
    );

    canvas.drawRect(deckRect, deckPaint);

    // Heavy equipment placeholder (excavator bucket shape)
    final equipmentPaint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;

    final equipmentRect = Rect.fromLTWH(
      -size.x / 2 + 5,
      size.y * 0.2,
      size.x - 10,
      size.y * 0.3,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(equipmentRect, const Radius.circular(4)),
      equipmentPaint,
    );

    // Wheels (many axles on lowboy)
    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (double y = size.y - 20; y < size.y; y += 8) {
      canvas.drawCircle(Offset(-size.x / 2 + 6, y), 4, wheelPaint);
      canvas.drawCircle(Offset(size.x / 2 - 6, y), 4, wheelPaint);
    }
  }

  /// Normalize angle to -PI to PI range
  double _normalizeAngle(double angle) {
    while (angle > 3.14159) angle -= 6.28318;
    while (angle < -3.14159) angle += 6.28318;
    return angle;
  }
}
