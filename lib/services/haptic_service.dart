/// Haptic Feedback Service
/// Handles vibration patterns for different collision types
library;

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

enum ImpactIntensity {
  light,    // Small collision - brief tap
  medium,   // Moderate hit - noticeable bump
  heavy,    // Big crash - strong thud
  extreme,  // Bridge hit, major damage - sustained shake
}

class HapticService {
  static bool _isEnabled = true;
  static bool _hasVibrator = false;
  static bool _hasAmplitudeControl = false;

  /// Initialize haptic service
  static Future<void> initialize() async {
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
      _hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;

      if (_hasVibrator) {
        print('Haptic feedback available');
        if (_hasAmplitudeControl) {
          print('Amplitude control supported');
        }
      } else {
        print('No vibrator available on this device');
      }
    } catch (e) {
      print('Error initializing haptics: $e');
      _hasVibrator = false;
    }
  }

  /// Enable/disable haptic feedback
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if haptics are available
  static bool get isAvailable => _hasVibrator && _isEnabled;

  /// Trigger impact feedback based on intensity
  static Future<void> impact(ImpactIntensity intensity) async {
    if (!isAvailable) return;

    try {
      switch (intensity) {
        case ImpactIntensity.light:
          await _lightImpact();
          break;
        case ImpactIntensity.medium:
          await _mediumImpact();
          break;
        case ImpactIntensity.heavy:
          await _heavyImpact();
          break;
        case ImpactIntensity.extreme:
          await _extremeImpact();
          break;
      }
    } catch (e) {
      print('Error triggering haptic: $e');
    }
  }

  /// Light impact - brief tap (20ms)
  static Future<void> _lightImpact() async {
    // Try Flutter's built-in haptic first
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Fallback to vibration package
      if (_hasAmplitudeControl) {
        await Vibration.vibrate(duration: 20, amplitude: 50);
      } else {
        await Vibration.vibrate(duration: 20);
      }
    }
  }

  /// Medium impact - noticeable bump (50ms)
  static Future<void> _mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (_hasAmplitudeControl) {
        await Vibration.vibrate(duration: 50, amplitude: 128);
      } else {
        await Vibration.vibrate(duration: 50);
      }
    }
  }

  /// Heavy impact - strong thud (100ms)
  static Future<void> _heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (_hasAmplitudeControl) {
        await Vibration.vibrate(duration: 100, amplitude: 200);
      } else {
        await Vibration.vibrate(duration: 100);
      }
    }
  }

  /// Extreme impact - sustained shake (pattern)
  /// Bridge hits, major damage, totaled truck
  static Future<void> _extremeImpact() async {
    if (_hasAmplitudeControl) {
      // Pattern: strong-pause-medium-pause-light
      // Simulates debris settling
      await Vibration.vibrate(
        pattern: [0, 150, 50, 100, 50, 50], // Wait, vibrate, wait, vibrate...
        intensities: [0, 255, 0, 180, 0, 100], // Decreasing intensity
      );
    } else {
      // Fallback: simple long vibration
      await Vibration.vibrate(duration: 300);
    }
  }

  /// Custom pattern for specific events
  static Future<void> customPattern({
    required List<int> pattern,
    List<int>? intensities,
  }) async {
    if (!isAvailable) return;

    try {
      if (_hasAmplitudeControl && intensities != null) {
        await Vibration.vibrate(
          pattern: pattern,
          intensities: intensities,
        );
      } else {
        await Vibration.vibrate(pattern: pattern);
      }
    } catch (e) {
      print('Error with custom pattern: $e');
    }
  }

  /// Collision-specific haptic patterns

  /// Four-wheeler hit - quick bump
  static Future<void> carCollision() async {
    await impact(ImpactIntensity.light);
  }

  /// Sign/barrier hit - medium thud
  static Future<void> obstacleCollision() async {
    await impact(ImpactIntensity.medium);
  }

  /// Bridge hit - THE BIG ONE!
  static Future<void> bridgeHit() async {
    await impact(ImpactIntensity.extreme);

    // Extra feedback after a delay (debris settling)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (isAvailable) {
        impact(ImpactIntensity.light);
      }
    });
  }

  /// Truck totaled - long sustained shake
  static Future<void> vehicleTotaled() async {
    if (!isAvailable) return;

    if (_hasAmplitudeControl) {
      // Long descending rumble
      await Vibration.vibrate(
        pattern: [0, 200, 100, 150, 100, 100, 100, 50],
        intensities: [0, 255, 0, 200, 0, 150, 0, 80],
      );
    } else {
      await Vibration.vibrate(duration: 500);
    }
  }

  /// Rapid hits - machine gun style (chain collisions)
  static Future<void> rapidHits(int count) async {
    if (!isAvailable) return;

    // Create pattern: tap-pause-tap-pause...
    List<int> pattern = [];
    List<int> intensities = [];

    for (int i = 0; i < count; i++) {
      pattern.addAll([0, 30, 30]); // Wait, vibrate, pause
      intensities.addAll([0, 150, 0]);
    }

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(pattern: pattern, intensities: intensities);
    } else {
      await Vibration.vibrate(pattern: pattern);
    }
  }

  /// Subtle rumble - truck engine idle (continuous low vibration)
  static Future<void> engineRumble() async {
    if (!isAvailable) return;

    if (_hasAmplitudeControl) {
      // Very subtle continuous vibration
      await Vibration.vibrate(duration: 100, amplitude: 30);
    }
  }

  /// Cancel all vibrations
  static Future<void> cancel() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      print('Error canceling vibration: $e');
    }
  }
}
