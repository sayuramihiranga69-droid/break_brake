/// Scrolling road background
/// Creates infinite road with lanes and markings
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class RoadComponent extends PositionComponent with HasGameReference {
  // Road properties
  static const double laneWidth = 80.0;
  static const int numberOfLanes = 3;
  static const double roadWidth = laneWidth * numberOfLanes;

  // Line marking properties
  static const double lineMarkingHeight = 40.0;
  static const double lineMarkingWidth = 8.0;
  static const double lineMarkingGap = 30.0;

  // Scroll speed (matches truck forward movement)
  double scrollSpeed = 200.0; // pixels per second

  // Line positions for animation
  List<double> lineMarkingPositions = [];

  // Colors
  static const Color roadColor = Color(0xFF404040);
  static const Color lineColor = Color(0xFFFFFFFF);
  static const Color shoulderColor = Color(0xFF2A2A2A);

  RoadComponent({Vector2? position})
      : super(
          position: position ?? Vector2.zero(),
          size: Vector2(roadWidth, 0), // Height will be screen height
          anchor: Anchor.topCenter,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set height to screen height
    size.y = game.size.y;

    // Initialize line marking positions
    _initializeLineMarkings();
  }

  void _initializeLineMarkings() {
    lineMarkingPositions.clear();

    // Create enough line markings to fill the screen + buffer
    double y = -lineMarkingHeight;
    while (y < size.y + lineMarkingHeight) {
      lineMarkingPositions.add(y);
      y += lineMarkingHeight + lineMarkingGap;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Scroll line markings
    for (int i = 0; i < lineMarkingPositions.length; i++) {
      lineMarkingPositions[i] += scrollSpeed * dt;

      // Wrap around when off screen
      if (lineMarkingPositions[i] > size.y + lineMarkingHeight) {
        lineMarkingPositions[i] =
            -lineMarkingHeight - (lineMarkingHeight + lineMarkingGap);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw road base
    _drawRoadBase(canvas);

    // Draw lane markings
    _drawLaneMarkings(canvas);

    // Draw shoulders
    _drawShoulders(canvas);
  }

  void _drawRoadBase(Canvas canvas) {
    final paint = Paint()
      ..color = roadColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      -size.x / 2,
      0,
      size.x,
      size.y,
    );

    canvas.drawRect(rect, paint);
  }

  void _drawLaneMarkings(Canvas canvas) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Draw center line (solid)
    final centerLineRect = Rect.fromLTWH(
      -lineMarkingWidth / 2,
      0,
      lineMarkingWidth,
      size.y,
    );
    canvas.drawRect(centerLineRect, paint);

    // Draw left lane divider (dashed)
    _drawDashedLine(canvas, -laneWidth, paint);

    // Draw right lane divider (dashed)
    _drawDashedLine(canvas, laneWidth, paint);
  }

  void _drawDashedLine(Canvas canvas, double xOffset, Paint paint) {
    for (double yPos in lineMarkingPositions) {
      final rect = Rect.fromLTWH(
        xOffset - lineMarkingWidth / 2,
        yPos,
        lineMarkingWidth,
        lineMarkingHeight,
      );
      canvas.drawRect(rect, paint);
    }
  }

  void _drawShoulders(Canvas canvas) {
    final paint = Paint()
      ..color = shoulderColor
      ..style = PaintingStyle.fill;

    // Left shoulder
    final leftShoulderRect = Rect.fromLTWH(
      -size.x / 2 - 40,
      0,
      40,
      size.y,
    );
    canvas.drawRect(leftShoulderRect, paint);

    // Right shoulder
    final rightShoulderRect = Rect.fromLTWH(
      size.x / 2,
      0,
      40,
      size.y,
    );
    canvas.drawRect(rightShoulderRect, paint);

    // Shoulder line markers (edge lines - solid yellow)
    final shoulderLinePaint = Paint()
      ..color = const Color(0xFFFFDD00)
      ..style = PaintingStyle.fill;

    // Left edge line
    canvas.drawRect(
      Rect.fromLTWH(-size.x / 2 - 2, 0, 4, size.y),
      shoulderLinePaint,
    );

    // Right edge line
    canvas.drawRect(
      Rect.fromLTWH(size.x / 2 - 2, 0, 4, size.y),
      shoulderLinePaint,
    );
  }

  /// Update scroll speed (based on truck speed)
  void updateScrollSpeed(double speed) {
    scrollSpeed = speed;
  }

  /// Get lane center X position
  double getLaneCenterX(int laneIndex) {
    // Lane 0 = left, 1 = center, 2 = right
    if (laneIndex == 0) return -laneWidth;
    if (laneIndex == 1) return 0;
    if (laneIndex == 2) return laneWidth;
    return 0;
  }

  /// Check if position is on road (vs shoulder)
  bool isOnRoad(Vector2 position) {
    final relativeX = position.x - this.position.x;
    return relativeX.abs() <= size.x / 2;
  }
}
