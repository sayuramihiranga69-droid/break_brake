/// Game Configuration and Constants
/// Central location for all game tuning parameters
library;

import 'package:flutter/material.dart';

/// Core game configuration
class GameConfig {
  // Screen and Display
  static const double gameWidth = 1920.0;
  static const double gameHeight = 1080.0;
  static const double targetFps = 60.0;

  // Physics Constants
  static const double gravity = 9.8;
  static const double pixelsPerMeter = 32.0;

  // Truck Physics
  static const double truckBaseSpeed = 200.0; // pixels per second
  static const double truckMaxSpeed = 400.0;
  static const double truckAcceleration = 100.0;
  static const double truckDeceleration = 150.0;
  static const double truckTurnSpeed = 2.0; // radians per second

  // Speed limits by career stage (mph for display)
  static const double companyDriverSpeedLimit = 65.0;
  static const double leaseOperatorSpeedLimit = 70.0;
  static const double ownerOperatorSpeedLimit = 999.0; // Ungoverned!

  // Damage System
  static const double maxDamagePoints = 100.0;
  static const double minorDamageThreshold = 25.0;
  static const double moderateDamageThreshold = 50.0;
  static const double severeDamageThreshold = 75.0;

  // Repair Times (in minutes)
  static const int lightRepairTime = 30;
  static const int moderateRepairTime = 120; // 2 hours
  static const int heavyRepairTime = 480; // 8 hours
  static const int totaledRepairTime = 720; // 12 hours

  // ELD System
  static const int eldDriveTimeLimit = 660; // 11 hours in minutes
  static const int eldWarningTime = 120; // 2 hours
  static const int eldCriticalTime = 30; // 30 minutes
  static const int eldResetTime = 600; // 10 hours break

  // Progression
  static const int companyDriverRunsRequired = 20;
  static const int leaseOperatorRunsRequired = 50;

  // Economy
  static const int baseDamagePointsPerHit = 10;
  static const int bridgeHitDPMultiplier = 5;
  static const int lowboyBridgeHitDPMultiplier = 10;
  static const int fourWheelerDP = 5;
  static const int signDP = 2;
  static const int barrierDP = 3;
}

/// Career stages
enum CareerStage {
  companyDriver,
  leaseOperator,
  ownerOperator,
}

/// Truck types
enum TruckType {
  // Cab-over classics
  freightlinerFLB,
  peterbilt362,
  kenworthK100,

  // Long-nose legends
  peterbilt379,
  kenworthW900,
  freightlinerClassicXL,
  international9900i,

  // Modern aero
  freightlinerCascadia,
  kenworthT680,
  volvoVNL,
}

/// Trailer types
enum TrailerType {
  dryVan,
  reefer,
  flatbed,
  tanker,
  lowboy,
  doubles,
  triples,
}

/// Game mode
enum GameMode {
  freePlay,
  hotLoad,
  skillChallenge,
  rageQuit,
}

/// Truck customization categories
enum CustomizationType {
  performance,
  chrome,
  lighting,
  paint,
  interior,
  madMax,
}

/// Achievement tiers
enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

/// Game colors and theme
class GameColors {
  // Career stage colors
  static const Color companyDriver = Color(0xFF8B0000); // Dark red (frustration)
  static const Color leaseOperator = Color(0xFFFF8C00); // Orange (transition)
  static const Color ownerOperator = Color(0xFF228B22); // Forest green (freedom)

  // UI colors
  static const Color damageRed = Color(0xFFFF0000);
  static const Color warningYellow = Color(0xFFFFD700);
  static const Color safeGreen = Color(0xFF00FF00);
  static const Color chromeShine = Color(0xFFE8E8E8);

  // ELD timer colors
  static const Color eldGreen = Color(0xFF00C853);
  static const Color eldYellow = Color(0xFFFFD600);
  static const Color eldRed = Color(0xFFFF1744);
}

/// String constants
class GameStrings {
  // Career stage names
  static const String companyDriverTitle = "Company Driver";
  static const String leaseOperatorTitle = "Lease Operator";
  static const String ownerOperatorTitle = "Owner Operator";

  // Taglines
  static const List<String> taglines = [
    "18 Wheels of Fury",
    "Take Out Your Road Rage",
    "Time to Raise Hell",
  ];

  // Dispatcher messages (company driver)
  static const List<String> dispatcherHarassment = [
    "Where are you?! Load was due 20 minutes ago!",
    "Customer calling every 5 minutes!",
    "Better not see delays on this one",
    "Three other drivers want your run if you can't handle it",
    "Why aren't you moving?",
    "You better not be sleeping!",
  ];

  // CB Radio chatter
  static const List<String> cbChatter = [
    "Got a maniac tearing up I-80!",
    "Smokey's gonna be all over that guy",
    "Did you see that?!",
    "Four-wheeler just got schooled",
    "Breaker breaker, you got your ears on?",
    "10-4 good buddy",
  ];
}

/// Trucker lingo
class TruckerLingo {
  static const String bear = "Bear"; // Police
  static const String smokey = "Smokey"; // Police
  static const String chickenCoop = "Chicken Coop"; // Weigh station
  static const String fourWheeler = "Four-Wheeler"; // Car
  static const String suicideJockey = "Suicide Jockey"; // Aggressive driver
  static const String alligator = "Alligator"; // Tire tread on road
  static const String hammerDown = "Hammer Down"; // Accelerate
  static const String wiggleWagon = "Wiggle Wagon"; // Double/triple trailer
}
