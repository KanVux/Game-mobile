import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/ui/menu/main_menu.dart';
import 'package:shieldbound/src/ui/menu/pause_menu.dart';
import 'package:shieldbound/src/ui/menu/settings_menu.dart';
import 'package:shieldbound/src/ui/game_over_screen.dart';
import 'hud_overlay.dart';

// Create providers
final gameProvider = StateProvider<Shieldbound?>((ref) => null);

class GameWrapper extends ConsumerStatefulWidget {
  const GameWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends ConsumerState<GameWrapper> {
  late Shieldbound game;
  bool showPauseMenu = false;

  @override
  void initState() {
    super.initState();

    game = Shieldbound();

    // Đặt trong try-catch để dễ debug
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(gameProvider.notifier).state = game;
        }
      });
    } catch (e) {
      debugPrint('Error initializing game: $e');
    }

    game.onGamePaused = () {
      if (mounted) {
        setState(() {
          showPauseMenu = true;
        });
      }
    };
  }

  void resumeGame() {
    setState(() {
      showPauseMenu = false;
      game.resumeGame();
    });
  }

  void openSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: SettingsMenu(),
          );
        },
      ),
    ).then((_) {
      // When returning from settings, keep the pause menu visible
      setState(() {
        showPauseMenu = true;
      });
    });
  }

  void returnToMainMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainMenu(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bỏ ProviderScope ở đây
      body: Stack(
        children: [
          RiverpodAwareGameWidget<Shieldbound>(
            key: GlobalKey(),
            game: game,
            overlayBuilderMap: {
              'GameOverScreen': (context, Shieldbound game) =>
                  const GameOverScreen(),
            },
            initialActiveOverlays: const [],
          ),
          if (showPauseMenu)
            PauseMenu(
              onResumePressed: resumeGame,
              onSettingsPressed: openSettings,
              onMainMenuPressed: returnToMainMenu,
            ),
          const HudOverlay(),
        ],
      ),
    );
  }
}
