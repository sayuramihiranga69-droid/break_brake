/// Damage system model
library;

import '../config/game_config.dart';

/// Tracks damage to a specific truck component
class ComponentDamage {
  final String component; // 'engine', 'windshield', 'tire_front_left', etc.
  double damageLevel; // 0.0 to 100.0
  bool isDestroyed;

  ComponentDamage({
    required this.component,
    this.damageLevel = 0.0,
    this.isDestroyed = false,
  });

  /// Add damage to this component
  void addDamage(double amount) {
    damageLevel = (damageLevel + amount).clamp(0.0, 100.0);
    if (damageLevel >= 100.0) {
      isDestroyed = true;
    }
  }

  /// Repair this component
  void repair(double amount) {
    damageLevel = (damageLevel - amount).clamp(0.0, 100.0);
    if (damageLevel < 100.0) {
      isDestroyed = false;
    }
  }

  /// Full repair
  void fullRepair() {
    damageLevel = 0.0;
    isDestroyed = false;
  }

  Map<String, dynamic> toJson() {
    return {
      'component': component,
      'damageLevel': damageLevel,
      'isDestroyed': isDestroyed,
    };
  }

  factory ComponentDamage.fromJson(Map<String, dynamic> json) {
    return ComponentDamage(
      component: json['component'],
      damageLevel: json['damageLevel'],
      isDestroyed: json['isDestroyed'],
    );
  }
}

/// Overall truck damage state
class TruckDamage {
  // Component-specific damage
  final Map<String, ComponentDamage> components = {};

  // Overall damage percentage
  double get totalDamage {
    if (components.isEmpty) return 0.0;
    double sum = 0.0;
    components.values.forEach((c) => sum += c.damageLevel);
    return sum / components.length;
  }

  // Is the truck totaled?
  bool get isTotaled => totalDamage >= GameConfig.maxDamagePoints;

  // Damage severity
  DamageSeverity get severity {
    if (totalDamage < GameConfig.minorDamageThreshold) {
      return DamageSeverity.none;
    } else if (totalDamage < GameConfig.moderateDamageThreshold) {
      return DamageSeverity.minor;
    } else if (totalDamage < GameConfig.severeDamageThreshold) {
      return DamageSeverity.moderate;
    } else if (totalDamage < GameConfig.maxDamagePoints) {
      return DamageSeverity.severe;
    } else {
      return DamageSeverity.totaled;
    }
  }

  // Repair time in minutes
  int get repairTimeMinutes {
    switch (severity) {
      case DamageSeverity.none:
        return 0;
      case DamageSeverity.minor:
        return GameConfig.lightRepairTime;
      case DamageSeverity.moderate:
        return GameConfig.moderateRepairTime;
      case DamageSeverity.severe:
        return GameConfig.heavyRepairTime;
      case DamageSeverity.totaled:
        return GameConfig.totaledRepairTime;
    }
  }

  TruckDamage() {
    _initializeComponents();
  }

  void _initializeComponents() {
    // Front-end
    components['hood'] = ComponentDamage(component: 'hood');
    components['bumper'] = ComponentDamage(component: 'bumper');
    components['grille'] = ComponentDamage(component: 'grille');
    components['headlight_left'] = ComponentDamage(component: 'headlight_left');
    components['headlight_right'] =
        ComponentDamage(component: 'headlight_right');

    // Windshield
    components['windshield'] = ComponentDamage(component: 'windshield');

    // Tires
    components['tire_front_left'] = ComponentDamage(component: 'tire_front_left');
    components['tire_front_right'] =
        ComponentDamage(component: 'tire_front_right');
    components['tire_rear_left'] = ComponentDamage(component: 'tire_rear_left');
    components['tire_rear_right'] =
        ComponentDamage(component: 'tire_rear_right');

    // Sides
    components['mirror_left'] = ComponentDamage(component: 'mirror_left');
    components['mirror_right'] = ComponentDamage(component: 'mirror_right');
    components['door_left'] = ComponentDamage(component: 'door_left');
    components['door_right'] = ComponentDamage(component: 'door_right');

    // Mechanical
    components['engine'] = ComponentDamage(component: 'engine');
    components['transmission'] = ComponentDamage(component: 'transmission');
    components['suspension'] = ComponentDamage(component: 'suspension');
  }

  /// Apply collision damage
  void applyCollisionDamage({
    required CollisionType type,
    required double impact,
    String? specificComponent,
  }) {
    double damageAmount = impact;

    switch (type) {
      case CollisionType.headOn:
        components['hood']?.addDamage(damageAmount);
        components['bumper']?.addDamage(damageAmount);
        components['grille']?.addDamage(damageAmount * 0.8);
        components['engine']?.addDamage(damageAmount * 0.5);
        break;

      case CollisionType.sideSwipe:
        components['door_left']?.addDamage(damageAmount);
        components['mirror_left']?.addDamage(damageAmount);
        break;

      case CollisionType.bridgeHit:
        // Roof/top damage - affects all components
        components.values.forEach((c) => c.addDamage(damageAmount * 0.3));
        components['windshield']?.addDamage(damageAmount);
        break;

      case CollisionType.rearEnd:
        // Less damage overall
        components.values.forEach((c) => c.addDamage(damageAmount * 0.2));
        break;
    }

    // Specific component damage if provided
    if (specificComponent != null && components.containsKey(specificComponent)) {
      components[specificComponent]?.addDamage(damageAmount);
    }
  }

  /// Performance penalty from damage
  double get speedPenalty {
    double engineDamage = components['engine']?.damageLevel ?? 0.0;
    double tireDamage = [
      components['tire_front_left']?.damageLevel ?? 0.0,
      components['tire_front_right']?.damageLevel ?? 0.0,
      components['tire_rear_left']?.damageLevel ?? 0.0,
      components['tire_rear_right']?.damageLevel ?? 0.0,
    ].reduce((a, b) => a + b) / 4;

    return ((engineDamage + tireDamage) / 2) * 0.01; // 0 to 1.0 multiplier
  }

  /// Handling penalty from damage
  double get handlingPenalty {
    double suspensionDamage = components['suspension']?.damageLevel ?? 0.0;
    double tireDamage = [
      components['tire_front_left']?.damageLevel ?? 0.0,
      components['tire_front_right']?.damageLevel ?? 0.0,
    ].reduce((a, b) => a + b) / 2;

    return ((suspensionDamage + tireDamage) / 2) * 0.01;
  }

  /// Full repair all components
  void fullRepair() {
    components.values.forEach((c) => c.fullRepair());
  }

  /// Partial repair (pit stop)
  void partialRepair(double percentage) {
    double repairAmount = GameConfig.maxDamagePoints * percentage;
    components.values.forEach((c) => c.repair(repairAmount));
  }

  Map<String, dynamic> toJson() {
    return {
      'components':
          components.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory TruckDamage.fromJson(Map<String, dynamic> json) {
    final damage = TruckDamage();
    if (json['components'] != null) {
      (json['components'] as Map<String, dynamic>).forEach((key, value) {
        damage.components[key] = ComponentDamage.fromJson(value);
      });
    }
    return damage;
  }
}

/// Damage severity levels
enum DamageSeverity {
  none,
  minor,
  moderate,
  severe,
  totaled,
}

/// Collision types
enum CollisionType {
  headOn,
  sideSwipe,
  bridgeHit,
  rearEnd,
}
