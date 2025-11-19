/// Game HUD - Heads Up Display
/// Shows speed, DP, damage, ELD timer, etc.
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../models/player_model.dart';
import '../../components/truck/truck_component.dart';
import '../../config/game_config.dart';

class GameHUD extends PositionComponent with HasGameReference {
  final PlayerModel playerModel;
  final TruckComponent truck;

  // Text renderers
  late TextPaint speedText;
  late TextPaint dpText;
  late TextPaint damageText;
  late TextPaint eldText;
  late TextPaint instructionsText;

  GameHUD({
    required this.playerModel,
    required this.truck,
  }) : super(
          priority: 100, // Render on top
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize text painters
    speedText = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    dpText = TextPaint(
      style: TextStyle(
        color: GameColors.ownerOperator,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    damageText = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    eldText = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    instructionsText = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 16,
        fontFamily: 'monospace',
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final screenSize = game.size;

    // Top-left: DP Counter
    _renderDPCounter(canvas, Vector2(20, 20));

    // Top-center: Speed
    _renderSpeed(canvas, Vector2(screenSize.x / 2, 20));

    // Top-right: Damage meter
    _renderDamageMeter(canvas, Vector2(screenSize.x - 220, 20));

    // Bottom-left: Instructions
    _renderInstructions(canvas, Vector2(20, screenSize.y - 100));

    // Bottom-right: Career stage indicator
    _renderCareerStage(canvas, Vector2(screenSize.x - 300, screenSize.y - 60));
  }

  void _renderDPCounter(Canvas canvas, Vector2 position) {
    // Background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.x, position.y, 180, 60),
      const Radius.circular(8),
    );

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRect, bgPaint);

    // DP label
    dpText.render(
      canvas,
      'DP: ${playerModel.damagePoints}',
      Vector2(position.x + 10, position.y + 15),
    );
  }

  void _renderSpeed(Canvas canvas, Vector2 position) {
    final speed = truck.getSpeedMph();

    // Background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.x - 100, position.y, 200, 70),
      const Radius.circular(8),
    );

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRect, bgPaint);

    // Speed text
    speedText.render(
      canvas,
      '$speed MPH',
      Vector2(position.x - 80, position.y + 15),
    );

    // Governor indicator if speed limited
    if (playerModel.careerStage != CareerStage.ownerOperator) {
      final governorText = TextPaint(
        style: TextStyle(
          color: GameColors.damageRed,
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      );

      final limit = playerModel.careerStage == CareerStage.companyDriver
          ? '65 MPH'
          : '70 MPH';

      governorText.render(
        canvas,
        'GOVERNED ($limit)',
        Vector2(position.x - 70, position.y + 50),
      );
    }
  }

  void _renderDamageMeter(Canvas canvas, Vector2 position) {
    final damage = playerModel.truckDamage.totalDamage;

    // Background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.x, position.y, 200, 60),
      const Radius.circular(8),
    );

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRect, bgPaint);

    // Damage bar background
    final barBgRect = Rect.fromLTWH(
      position.x + 10,
      position.y + 35,
      180,
      15,
    );

    final barBgPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    canvas.drawRect(barBgRect, barBgPaint);

    // Damage bar fill
    final damagePercent = (damage / 100.0).clamp(0.0, 1.0);
    final barFillRect = Rect.fromLTWH(
      position.x + 10,
      position.y + 35,
      180 * damagePercent,
      15,
    );

    Color damageColor;
    if (damage < 25) {
      damageColor = GameColors.safeGreen;
    } else if (damage < 50) {
      damageColor = GameColors.warningYellow;
    } else {
      damageColor = GameColors.damageRed;
    }

    final barFillPaint = Paint()
      ..color = damageColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(barFillRect, barFillPaint);

    // Label
    damageText.render(
      canvas,
      'DAMAGE: ${damage.toInt()}%',
      Vector2(position.x + 10, position.y + 8),
    );
  }

  void _renderInstructions(Canvas canvas, Vector2 position) {
    final lines = [
      'CONTROLS:',
      'Arrow Keys / WASD - Steer',
      'Space - Brake',
      'Tap Left/Right - Steer (touch)',
    ];

    double yOffset = 0;
    for (final line in lines) {
      instructionsText.render(
        canvas,
        line,
        Vector2(position.x, position.y + yOffset),
      );
      yOffset += 20;
    }
  }

  void _renderCareerStage(Canvas canvas, Vector2 position) {
    final stageText = TextPaint(
      style: TextStyle(
        color: _getCareerColor(),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    // Background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.x, position.y, 280, 50),
      const Radius.circular(8),
    );

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRect, bgPaint);

    stageText.render(
      canvas,
      playerModel.getCareerStageTitle().toUpperCase(),
      Vector2(position.x + 10, position.y + 15),
    );
  }

  Color _getCareerColor() {
    switch (playerModel.careerStage) {
      case CareerStage.companyDriver:
        return GameColors.companyDriver;
      case CareerStage.leaseOperator:
        return GameColors.leaseOperator;
      case CareerStage.ownerOperator:
        return GameColors.ownerOperator;
    }
  }
}
