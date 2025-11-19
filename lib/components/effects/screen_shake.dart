/// Screen shake effect for impact feedback
/// Creates camera shake with configurable intensity and duration
library;

import 'dart:math';
import 'package:flame/components.dart';

enum ShakeIntensity {
  light,    // Minor collision - subtle shake
  medium,   // Moderate hit - noticeable shake
  heavy,    // Big crash - strong shake
  extreme,  // Bridge/totaled - violent shake
}

class ScreenShake extends Component {
  double shakeTimer = 0;
  double shakeDuration = 0;
  double shakeIntensity = 0;
  double shakeFrequency = 30; // Hz - how fast it oscillates

  final Random _random = Random();

  // Current shake offset
  Vector2 currentOffset = Vector2.zero();

  bool get isShaking => shakeTimer < shakeDuration;

  /// Trigger a screen shake effect
  void shake({
    required ShakeIntensity intensity,
    double? customDuration,
    double? customIntensity,
  }) {
    // Set duration based on intensity
    switch (intensity) {
      case ShakeIntensity.light:
        shakeDuration = customDuration ?? 0.15;
        shakeIntensity = customIntensity ?? 3.0;
        shakeFrequency = 35;
        break;
      case ShakeIntensity.medium:
        shakeDuration = customDuration ?? 0.25;
        shakeIntensity = customIntensity ?? 6.0;
        shakeFrequency = 30;
        break;
      case ShakeIntensity.heavy:
        shakeDuration = customDuration ?? 0.4;
        shakeIntensity = customIntensity ?? 10.0;
        shakeFrequency = 25;
        break;
      case ShakeIntensity.extreme:
        shakeDuration = customDuration ?? 0.6;
        shakeIntensity = customIntensity ?? 18.0;
        shakeFrequency = 20;
        break;
    }

    // Reset timer
    shakeTimer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isShaking) {
      currentOffset = Vector2.zero();
      return;
    }

    shakeTimer += dt;

    // Calculate decay (shake reduces over time)
    final progress = shakeTimer / shakeDuration;
    final decay = 1.0 - progress;

    // Calculate shake offset using random direction and decaying magnitude
    if (decay > 0) {
      final magnitude = shakeIntensity * decay;

      // Use sine wave for smoother oscillation with random direction changes
      final oscillation = sin(shakeTimer * shakeFrequency);

      // Random direction that changes periodically
      final randomAngle = _random.nextDouble() * 6.28; // 2π radians

      currentOffset = Vector2(
        cos(randomAngle) * magnitude * oscillation,
        sin(randomAngle) * magnitude * oscillation,
      );
    } else {
      currentOffset = Vector2.zero();
    }
  }

  /// Get the current shake offset to apply to camera
  Vector2 getOffset() => currentOffset;

  /// Stop shake immediately
  void stop() {
    shakeTimer = shakeDuration;
    currentOffset = Vector2.zero();
  }
}
