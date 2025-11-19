/// Truck data model
library;

import '../config/game_config.dart';

class TruckModel {
  final String id;
  final String name;
  final TruckType type;

  // Performance stats
  final double baseSpeed;
  final double maxSpeed;
  final double acceleration;
  final double handling;

  // Visual customization
  String paintColor;
  List<String> chromePackages;
  List<String> lights;
  bool hasMadMaxUpgrades;

  // Upgrades
  int engineLevel;
  int suspensionLevel;
  int jakebrakeLevel;

  // Unlock requirements
  final int unlockCost;
  final CareerStage requiredStage;
  final bool isUnlocked;

  TruckModel({
    required this.id,
    required this.name,
    required this.type,
    required this.baseSpeed,
    required this.maxSpeed,
    required this.acceleration,
    required this.handling,
    this.paintColor = '#FFFFFF',
    this.chromePackages = const [],
    this.lights = const [],
    this.hasMadMaxUpgrades = false,
    this.engineLevel = 1,
    this.suspensionLevel = 1,
    this.jakebrakeLevel = 1,
    required this.unlockCost,
    required this.requiredStage,
    this.isUnlocked = false,
  });

  /// Calculate current max speed with upgrades and governor
  double getEffectiveMaxSpeed(CareerStage currentStage) {
    double speed = maxSpeed + (engineLevel * 10);

    // Apply governor based on career stage
    switch (currentStage) {
      case CareerStage.companyDriver:
        return speed.clamp(0, GameConfig.companyDriverSpeedLimit);
      case CareerStage.leaseOperator:
        return speed.clamp(0, GameConfig.leaseOperatorSpeedLimit);
      case CareerStage.ownerOperator:
        return speed; // FREEDOM!
    }
  }

  /// Calculate handling with suspension upgrades
  double getEffectiveHandling() {
    return handling + (suspensionLevel * 0.1);
  }

  TruckModel copyWith({
    String? paintColor,
    List<String>? chromePackages,
    List<String>? lights,
    bool? hasMadMaxUpgrades,
    int? engineLevel,
    int? suspensionLevel,
    int? jakebrakeLevel,
    bool? isUnlocked,
  }) {
    return TruckModel(
      id: id,
      name: name,
      type: type,
      baseSpeed: baseSpeed,
      maxSpeed: maxSpeed,
      acceleration: acceleration,
      handling: handling,
      paintColor: paintColor ?? this.paintColor,
      chromePackages: chromePackages ?? this.chromePackages,
      lights: lights ?? this.lights,
      hasMadMaxUpgrades: hasMadMaxUpgrades ?? this.hasMadMaxUpgrades,
      engineLevel: engineLevel ?? this.engineLevel,
      suspensionLevel: suspensionLevel ?? this.suspensionLevel,
      jakebrakeLevel: jakebrakeLevel ?? this.jakebrakeLevel,
      unlockCost: unlockCost,
      requiredStage: requiredStage,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'paintColor': paintColor,
      'chromePackages': chromePackages,
      'lights': lights,
      'hasMadMaxUpgrades': hasMadMaxUpgrades,
      'engineLevel': engineLevel,
      'suspensionLevel': suspensionLevel,
      'jakebrakeLevel': jakebrakeLevel,
      'isUnlocked': isUnlocked,
    };
  }

  factory TruckModel.fromJson(Map<String, dynamic> json, TruckModel template) {
    return template.copyWith(
      paintColor: json['paintColor'] as String?,
      chromePackages: (json['chromePackages'] as List?)?.cast<String>(),
      lights: (json['lights'] as List?)?.cast<String>(),
      hasMadMaxUpgrades: json['hasMadMaxUpgrades'] as bool?,
      engineLevel: json['engineLevel'] as int?,
      suspensionLevel: json['suspensionLevel'] as int?,
      jakebrakeLevel: json['jakebrakeLevel'] as int?,
      isUnlocked: json['isUnlocked'] as bool?,
    );
  }
}

/// Predefined truck templates
class TruckTemplates {
  static final List<TruckModel> allTrucks = [
    // Company Driver Starter Truck
    TruckModel(
      id: 'cascadia_basic',
      name: 'Freightliner Cascadia',
      type: TruckType.freightlinerCascadia,
      baseSpeed: 180,
      maxSpeed: 260, // Will be governed
      acceleration: 80,
      handling: 0.7,
      unlockCost: 0,
      requiredStage: CareerStage.companyDriver,
      isUnlocked: true,
    ),

    // Cab-Over Classics
    TruckModel(
      id: 'flb_classic',
      name: 'Freightliner FLB',
      type: TruckType.freightlinerFLB,
      baseSpeed: 170,
      maxSpeed: 240,
      acceleration: 75,
      handling: 0.8,
      unlockCost: 5000,
      requiredStage: CareerStage.leaseOperator,
    ),

    TruckModel(
      id: 'pete_362',
      name: 'Peterbilt 362',
      type: TruckType.peterbilt362,
      baseSpeed: 175,
      maxSpeed: 250,
      acceleration: 80,
      handling: 0.75,
      unlockCost: 7500,
      requiredStage: CareerStage.leaseOperator,
    ),

    // Long-Nose Legends
    TruckModel(
      id: 'pete_379',
      name: 'Peterbilt 379',
      type: TruckType.peterbilt379,
      baseSpeed: 190,
      maxSpeed: 280,
      acceleration: 90,
      handling: 0.8,
      unlockCost: 15000,
      requiredStage: CareerStage.ownerOperator,
    ),

    TruckModel(
      id: 'kw_w900',
      name: 'Kenworth W900',
      type: TruckType.kenworthW900,
      baseSpeed: 195,
      maxSpeed: 290,
      acceleration: 95,
      handling: 0.85,
      unlockCost: 18000,
      requiredStage: CareerStage.ownerOperator,
    ),

    TruckModel(
      id: 'fl_classic_xl',
      name: 'Freightliner Classic XL',
      type: TruckType.freightlinerClassicXL,
      baseSpeed: 200,
      maxSpeed: 300,
      acceleration: 100,
      handling: 0.9,
      unlockCost: 20000,
      requiredStage: CareerStage.ownerOperator,
    ),
  ];

  static TruckModel getDefaultTruck() {
    return allTrucks.first;
  }

  static TruckModel? getTruckById(String id) {
    try {
      return allTrucks.firstWhere((truck) => truck.id == id);
    } catch (e) {
      return null;
    }
  }
}
