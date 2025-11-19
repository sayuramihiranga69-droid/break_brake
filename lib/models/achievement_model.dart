/// Achievement system model
library;

import '../config/game_config.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementTier tier;
  final AchievementCategory category;

  // Progress tracking
  final int targetValue; // e.g., "Hit 10 bridges"
  int currentValue;
  bool get isUnlocked => currentValue >= targetValue;

  // Rewards
  final List<String> rewards; // IDs of unlocked items
  final int dpReward;
  final int cashReward;

  // Display
  final String icon;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    this.rewards = const [],
    this.dpReward = 0,
    this.cashReward = 0,
    this.icon = '🏆',
  });

  /// Increment progress
  void incrementProgress([int amount = 1]) {
    if (!isUnlocked) {
      currentValue += amount;
    }
  }

  /// Get progress percentage
  double get progressPercentage {
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  Achievement copyWith({
    int? currentValue,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      tier: tier,
      category: category,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      rewards: rewards,
      dpReward: dpReward,
      cashReward: cashReward,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentValue': currentValue,
    };
  }

  factory Achievement.fromJson(
      Map<String, dynamic> json, Achievement template) {
    return template.copyWith(
      currentValue: json['currentValue'] as int?,
    );
  }
}

/// Achievement categories
enum AchievementCategory {
  career,
  bridges,
  destruction,
  dispatcher,
  ownerOp,
  style,
  special,
}

/// Predefined achievements
class AchievementTemplates {
  static final List<Achievement> allAchievements = [
    // === Career Path ===
    Achievement(
      id: 'rookie_mistake',
      name: 'Rookie Mistake',
      description: 'Complete your first company driver run',
      tier: AchievementTier.bronze,
      category: AchievementCategory.career,
      targetValue: 1,
      dpReward: 50,
      icon: '🚛',
    ),

    Achievement(
      id: 'lease_to_own',
      name: 'Lease to Own',
      description: 'Reach lease operator status',
      tier: AchievementTier.silver,
      category: AchievementCategory.career,
      targetValue: 1,
      dpReward: 500,
      rewards: ['chrome_basic_package'],
      icon: '📋',
    ),

    Achievement(
      id: 'my_name_on_door',
      name: 'My Name on the Door',
      description: 'Become an owner operator',
      tier: AchievementTier.gold,
      category: AchievementCategory.career,
      targetValue: 1,
      dpReward: 2000,
      rewards: ['custom_decals', 'company_name_plate'],
      icon: '👑',
    ),

    Achievement(
      id: 'war_rig_complete',
      name: 'War Rig Complete',
      description: 'Install all Mad Max upgrades',
      tier: AchievementTier.platinum,
      category: AchievementCategory.career,
      targetValue: 1,
      dpReward: 5000,
      rewards: ['war_rig_complete_package'],
      icon: '💀',
    ),

    // === Bridge Hunter Collection ===
    Achievement(
      id: 'can_opener_apprentice',
      name: 'Can Opener Apprentice',
      description: 'Hit your first bridge',
      tier: AchievementTier.bronze,
      category: AchievementCategory.bridges,
      targetValue: 1,
      dpReward: 100,
      icon: '🌉',
    ),

    Achievement(
      id: 'eleven_eight_club',
      name: 'The 11\'8" Club',
      description: 'Hit the legendary bridge',
      tier: AchievementTier.gold,
      category: AchievementCategory.bridges,
      targetValue: 1,
      dpReward: 1000,
      rewards: ['height_stick_ornament'],
      icon: '⚠️',
    ),

    Achievement(
      id: 'bridge_collector',
      name: 'Bridge Collector',
      description: 'Hit 10 different bridges',
      tier: AchievementTier.silver,
      category: AchievementCategory.bridges,
      targetValue: 10,
      dpReward: 500,
      rewards: ['caution_stripe_paint'],
      icon: '🎯',
    ),

    Achievement(
      id: 'infrastructure_terrorist',
      name: 'Infrastructure Terrorist',
      description: 'Damage a bridge with heavy equipment',
      tier: AchievementTier.platinum,
      category: AchievementCategory.bridges,
      targetValue: 1,
      dpReward: 5000,
      rewards: ['industrial_yellow_paint', 'hazard_decals'],
      icon: '💥',
    ),

    Achievement(
      id: 'swift_justice',
      name: 'Swift Justice',
      description: 'Hit 10 low bridges (industry joke)',
      tier: AchievementTier.gold,
      category: AchievementCategory.bridges,
      targetValue: 10,
      dpReward: 1500,
      icon: '😏',
    ),

    // === Destruction Specialist ===
    Achievement(
      id: 'four_wheeler_bowling',
      name: 'Four-Wheeler Bowling',
      description: 'Destroy 100 cars',
      tier: AchievementTier.silver,
      category: AchievementCategory.destruction,
      targetValue: 100,
      dpReward: 300,
      icon: '🎳',
    ),

    Achievement(
      id: 'sign_language',
      name: 'Sign Language',
      description: 'Destroy 500 road signs',
      tier: AchievementTier.silver,
      category: AchievementCategory.destruction,
      targetValue: 500,
      dpReward: 500,
      icon: '🪧',
    ),

    Achievement(
      id: 'chicken_coop_crasher',
      name: 'Chicken Coop Crasher',
      description: 'Escape 10 weigh stations',
      tier: AchievementTier.gold,
      category: AchievementCategory.destruction,
      targetValue: 10,
      dpReward: 1000,
      rewards: ['rebel_decals'],
      icon: '🚨',
    ),

    Achievement(
      id: 'combo_king',
      name: 'Combo King',
      description: 'Chain 10+ destruction events in one combo',
      tier: AchievementTier.gold,
      category: AchievementCategory.destruction,
      targetValue: 1,
      dpReward: 1500,
      icon: '⚡',
    ),

    // === Dispatcher's Nightmare ===
    Achievement(
      id: 'ignored_call',
      name: 'Ignored Call',
      description: 'Ignore 10 dispatcher calls',
      tier: AchievementTier.bronze,
      category: AchievementCategory.dispatcher,
      targetValue: 10,
      dpReward: 100,
      icon: '📵',
    ),

    Achievement(
      id: 'violation_vacation',
      name: 'Violation Vacation',
      description: 'Accumulate 50 ELD violations',
      tier: AchievementTier.silver,
      category: AchievementCategory.dispatcher,
      targetValue: 50,
      dpReward: 500,
      icon: '⏰',
    ),

    Achievement(
      id: 'rage_quit',
      name: 'RAGE QUIT',
      description: 'Complete a rebellion rampage',
      tier: AchievementTier.platinum,
      category: AchievementCategory.dispatcher,
      targetValue: 1,
      dpReward: 3000,
      rewards: ['rebel_theme_package'],
      icon: '🔥',
    ),

    Achievement(
      id: 'youre_fired',
      name: 'You\'re Fired!',
      description: 'Reach owner-op status (silence dispatcher forever)',
      tier: AchievementTier.gold,
      category: AchievementCategory.dispatcher,
      targetValue: 1,
      dpReward: 2000,
      rewards: ['freedom_theme'],
      icon: '✊',
    ),

    // === Owner-Op Status ===
    Achievement(
      id: 'chrome_king',
      name: 'Chrome King',
      description: 'Fully chrome out a truck',
      tier: AchievementTier.gold,
      category: AchievementCategory.ownerOp,
      targetValue: 1,
      dpReward: 1000,
      rewards: ['gold_plated_chrome'],
      icon: '✨',
    ),

    Achievement(
      id: 'dream_rig',
      name: 'Dream Rig',
      description: 'Build your perfect custom truck',
      tier: AchievementTier.platinum,
      category: AchievementCategory.ownerOp,
      targetValue: 1,
      dpReward: 5000,
      icon: '💎',
    ),

    Achievement(
      id: 'no_governor',
      name: 'No Governor, No Problem',
      description: 'Run ungoverned for 100 miles',
      tier: AchievementTier.gold,
      category: AchievementCategory.ownerOp,
      targetValue: 100,
      dpReward: 1500,
      icon: '🚀',
    ),

    // === Style Points ===
    Achievement(
      id: 'perfect_jump',
      name: 'Perfect Jump',
      description: 'Clean bridge jump landing',
      tier: AchievementTier.silver,
      category: AchievementCategory.style,
      targetValue: 1,
      dpReward: 500,
      icon: '🦅',
    ),

    Achievement(
      id: 'the_duke',
      name: 'The Duke',
      description: 'Complete 10 perfect jumps',
      tier: AchievementTier.platinum,
      category: AchievementCategory.style,
      targetValue: 10,
      dpReward: 5000,
      rewards: ['rebel_flag_decal', 'air_horn_dixie'],
      icon: '🏁',
    ),

    Achievement(
      id: 'jackknife_genius',
      name: 'Jackknife Genius',
      description: 'Intentional jackknife takes out 10 targets',
      tier: AchievementTier.gold,
      category: AchievementCategory.style,
      targetValue: 1,
      dpReward: 2000,
      icon: '🌪️',
    ),

    // === Special Achievements ===
    Achievement(
      id: 'instant_thaw',
      name: 'Instant Thaw',
      description: 'Spectacular reefer explosion',
      tier: AchievementTier.silver,
      category: AchievementCategory.special,
      targetValue: 1,
      dpReward: 750,
      icon: '🧊',
    ),

    Achievement(
      id: 'wiggle_wagon_wipeout',
      name: 'Wiggle Wagon Wipeout',
      description: 'Destroy all trailers in a triple setup',
      tier: AchievementTier.gold,
      category: AchievementCategory.special,
      targetValue: 1,
      dpReward: 2000,
      icon: '🐍',
    ),

    Achievement(
      id: 'bonehead_of_week',
      name: 'Bonehead of the Week',
      description: 'Create a truly spectacular wreck',
      tier: AchievementTier.platinum,
      category: AchievementCategory.special,
      targetValue: 1,
      dpReward: 10000,
      rewards: ['bonehead_trophy', 'viral_fame_decal'],
      icon: '🤦',
    ),
  ];

  static Achievement? getAchievementById(String id) {
    try {
      return allAchievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Achievement> getAchievementsByCategory(
      AchievementCategory category) {
    return allAchievements.where((a) => a.category == category).toList();
  }

  static List<Achievement> getAchievementsByTier(AchievementTier tier) {
    return allAchievements.where((a) => a.tier == tier).toList();
  }
}
