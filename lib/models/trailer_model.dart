/// Trailer data model
library;

import '../config/game_config.dart';

class TrailerModel {
  final String id;
  final String name;
  final TrailerType type;

  // Destruction properties
  final bool canExplode; // Reefer spectacular explosion
  final bool hasLiquid; // Tanker slosh physics
  final bool canPeelRoof; // Dry van can-opener
  final double damageMultiplier; // How much damage it takes/gives

  // Unlock requirements
  final int unlockCost;
  final CareerStage requiredStage;
  final bool isUnlocked;

  // Cargo (affects destruction effects)
  String? currentCargo;

  TrailerModel({
    required this.id,
    required this.name,
    required this.type,
    this.canExplode = false,
    this.hasLiquid = false,
    this.canPeelRoof = false,
    required this.damageMultiplier,
    required this.unlockCost,
    required this.requiredStage,
    this.isUnlocked = false,
    this.currentCargo,
  });

  /// Get destruction description for this trailer type
  String getDestructionDescription() {
    switch (type) {
      case TrailerType.dryVan:
        return "Classic can-opener peel, cargo spills everywhere";
      case TrailerType.reefer:
        return "MASSIVE insulation explosion, white cloud, totaled";
      case TrailerType.flatbed:
        return "Cargo scrapes obstacles, chains snap";
      case TrailerType.tanker:
        return "Liquid slosh, rupture, hazmat chaos";
      case TrailerType.lowboy:
        return "Heavy equipment damages BRIDGES - 10x DP!";
      case TrailerType.doubles:
        return "Each trailer impacts separately, chain reaction";
      case TrailerType.triples:
        return "Wiggle wagon wipeout, maximum chaos";
    }
  }

  /// Get DP multiplier for bridge hits
  int getBridgeHitMultiplier() {
    switch (type) {
      case TrailerType.lowboy:
        return GameConfig.lowboyBridgeHitDPMultiplier;
      case TrailerType.reefer:
        return GameConfig.bridgeHitDPMultiplier + 2; // Spectacular!
      case TrailerType.dryVan:
        return GameConfig.bridgeHitDPMultiplier;
      default:
        return GameConfig.bridgeHitDPMultiplier - 1;
    }
  }

  TrailerModel copyWith({
    bool? isUnlocked,
    String? currentCargo,
  }) {
    return TrailerModel(
      id: id,
      name: name,
      type: type,
      canExplode: canExplode,
      hasLiquid: hasLiquid,
      canPeelRoof: canPeelRoof,
      damageMultiplier: damageMultiplier,
      unlockCost: unlockCost,
      requiredStage: requiredStage,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentCargo: currentCargo ?? this.currentCargo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'isUnlocked': isUnlocked,
      'currentCargo': currentCargo,
    };
  }
}

/// Predefined trailer templates
class TrailerTemplates {
  static final List<TrailerModel> allTrailers = [
    // Dry Van - Standard, always available
    TrailerModel(
      id: 'dry_van_53',
      name: '53\' Dry Van',
      type: TrailerType.dryVan,
      canPeelRoof: true,
      damageMultiplier: 1.0,
      unlockCost: 0,
      requiredStage: CareerStage.companyDriver,
      isUnlocked: true,
    ),

    // Reefer - Spectacular destruction
    TrailerModel(
      id: 'reefer_53',
      name: '53\' Refrigerated',
      type: TrailerType.reefer,
      canExplode: true,
      canPeelRoof: true,
      damageMultiplier: 1.5,
      unlockCost: 2000,
      requiredStage: CareerStage.companyDriver,
    ),

    // Flatbed
    TrailerModel(
      id: 'flatbed_48',
      name: '48\' Flatbed',
      type: TrailerType.flatbed,
      damageMultiplier: 0.8,
      unlockCost: 3000,
      requiredStage: CareerStage.leaseOperator,
    ),

    // Tanker
    TrailerModel(
      id: 'tanker_48',
      name: '48\' Tanker',
      type: TrailerType.tanker,
      hasLiquid: true,
      damageMultiplier: 2.0,
      unlockCost: 5000,
      requiredStage: CareerStage.leaseOperator,
    ),

    // Lowboy - THE BRIDGE KILLER
    TrailerModel(
      id: 'lowboy_heavy',
      name: 'Lowboy with Excavator',
      type: TrailerType.lowboy,
      damageMultiplier: 3.0,
      unlockCost: 15000,
      requiredStage: CareerStage.ownerOperator,
    ),

    // Doubles
    TrailerModel(
      id: 'doubles_28',
      name: '28\' Doubles',
      type: TrailerType.doubles,
      damageMultiplier: 1.5,
      unlockCost: 7500,
      requiredStage: CareerStage.ownerOperator,
    ),

    // Triples - Maximum chaos
    TrailerModel(
      id: 'triples_28',
      name: '28\' Triples (Wiggle Wagon)',
      type: TrailerType.triples,
      damageMultiplier: 2.0,
      unlockCost: 12000,
      requiredStage: CareerStage.ownerOperator,
    ),
  ];

  static TrailerModel getDefaultTrailer() {
    return allTrailers.first;
  }

  static TrailerModel? getTrailerById(String id) {
    try {
      return allTrailers.firstWhere((trailer) => trailer.id == id);
    } catch (e) {
      return null;
    }
  }
}
