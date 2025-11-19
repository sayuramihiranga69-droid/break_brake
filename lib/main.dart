import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';

import 'providers/game_state_provider.dart';
import 'game/breaker_braker_game.dart';
import 'config/game_config.dart';
import 'services/haptic_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  // Set fullscreen mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize haptic feedback
  await HapticService.initialize();

  runApp(const BreakerBrakerApp());
}

class BreakerBrakerApp extends StatelessWidget {
  const BreakerBrakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameStateProvider(),
      child: MaterialApp(
        title: 'Breaker Braker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: GameColors.ownerOperator,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'monospace',
          colorScheme: ColorScheme.dark(
            primary: GameColors.ownerOperator,
            secondary: GameColors.chromeShine,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

/// Splash screen with loading
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);

    // Load saved game data
    await gameState.loadGameData();

    // Small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      // Navigate to main menu
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenu()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              GameColors.companyDriver.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'BREAKER BRAKER',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: GameColors.chromeShine,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: GameColors.ownerOperator,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tagline
              Text(
                '18 Wheels of Fury',
                style: TextStyle(
                  fontSize: 24,
                  color: GameColors.chromeShine.withOpacity(0.7),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              if (_isLoading)
                Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GameColors.ownerOperator,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Firing up the diesel...',
                      style: TextStyle(
                        color: GameColors.chromeShine.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main menu screen
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameStateProvider>(
        builder: (context, gameState, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  _getCareerStageColor(gameState.player.careerStage)
                      .withOpacity(0.3),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  children: [
                    // Left side - Menu options
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            'BREAKER BRAKER',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: GameColors.chromeShine,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Career stage
                          Text(
                            gameState.player.getCareerStageTitle(),
                            style: TextStyle(
                              fontSize: 20,
                              color: _getCareerStageColor(
                                  gameState.player.careerStage),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Menu buttons
                          _MenuButton(
                            label: 'FREE PLAY',
                            icon: Icons.local_shipping,
                            onPressed: () {
                              _startGame(context, GameMode.freePlay);
                            },
                          ),
                          const SizedBox(height: 16),

                          _MenuButton(
                            label: 'HOT LOAD',
                            icon: Icons.timer,
                            onPressed: () {
                              _startGame(context, GameMode.hotLoad);
                            },
                          ),
                          const SizedBox(height: 16),

                          _MenuButton(
                            label: 'GARAGE',
                            icon: Icons.build,
                            onPressed: () {
                              // TODO: Navigate to garage
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Garage coming soon!')),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          _MenuButton(
                            label: 'ACHIEVEMENTS',
                            icon: Icons.emoji_events,
                            onPressed: () {
                              // TODO: Navigate to achievements
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Achievements coming soon!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Right side - Stats and status
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top stats
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _StatDisplay(
                                label: 'DP',
                                value:
                                    '${gameState.player.damagePoints}',
                                icon: Icons.attach_money,
                              ),
                              const SizedBox(height: 8),
                              _StatDisplay(
                                label: 'CASH',
                                value: '\$${gameState.player.cash}',
                                icon: Icons.account_balance_wallet,
                              ),
                              const SizedBox(height: 8),
                              _StatDisplay(
                                label: 'RUNS',
                                value:
                                    '${gameState.player.runsCompleted}',
                                icon: Icons.route,
                              ),
                            ],
                          ),

                          // Truck status
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: GameColors.chromeShine
                                    .withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'CURRENT RIG',
                                  style: TextStyle(
                                    color: GameColors.chromeShine
                                        .withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  gameState.getCurrentTruck()?.name ??
                                      'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  gameState
                                          .getCurrentTrailer()
                                          ?.name ??
                                      'Unknown',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 16),

                                // Repair status
                                if (gameState.player.isUnderRepair)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.build,
                                            color: GameColors.warningYellow,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'UNDER REPAIR',
                                            style: TextStyle(
                                              color:
                                                  GameColors.warningYellow,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${gameState.player.getRemainingRepairTime()} min remaining',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: GameColors.safeGreen,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'READY TO ROLL',
                                        style: TextStyle(
                                          color: GameColors.safeGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCareerStageColor(CareerStage stage) {
    switch (stage) {
      case CareerStage.companyDriver:
        return GameColors.companyDriver;
      case CareerStage.leaseOperator:
        return GameColors.leaseOperator;
      case CareerStage.ownerOperator:
        return GameColors.ownerOperator;
    }
  }

  void _startGame(BuildContext context, GameMode mode) {
    final gameState =
        Provider.of<GameStateProvider>(context, listen: false);

    // Check if truck is under repair
    if (gameState.player.isUnderRepair) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Truck is under repair! ${gameState.player.getRemainingRepairTime()} minutes remaining.',
          ),
          backgroundColor: GameColors.damageRed,
        ),
      );
      return;
    }

    gameState.startGame(mode);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(mode: mode),
      ),
    );
  }
}

/// Game screen with Flame game
class GameScreen extends StatefulWidget {
  final GameMode mode;

  const GameScreen({super.key, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BreakerBrakerGame _game;

  @override
  void initState() {
    super.initState();
    final gameState =
        Provider.of<GameStateProvider>(context, listen: false);
    _game = BreakerBrakerGame(gameState: gameState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: _game),
    );
  }
}

/// Menu button widget
class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: GameColors.chromeShine,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: GameColors.chromeShine.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat display widget
class _StatDisplay extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatDisplay({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: GameColors.ownerOperator, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: TextStyle(
                color: GameColors.chromeShine.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
