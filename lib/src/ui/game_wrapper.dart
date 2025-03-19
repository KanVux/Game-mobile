import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/ui/menu/main_menu.dart';
import 'package:shieldbound/src/ui/menu/pause_menu.dart';
import 'package:shieldbound/src/ui/menu/settings_menu.dart';

class GameWrapper extends StatefulWidget {
  const GameWrapper({Key? key}) : super(key: key);

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late Shieldbound game;
  bool showPauseMenu = false;

  @override
  void initState() {
    super.initState();
    game = Shieldbound();

    // Set up the pause callback
    game.onGamePaused = () {
      setState(() {
        showPauseMenu = true;
      });
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
      body: Stack(
        children: [
          GameWidget(game: game),
          if (showPauseMenu)
            PauseMenu(
              onResumePressed: resumeGame,
              onSettingsPressed: openSettings,
              onMainMenuPressed: returnToMainMenu,
            ),
        ],
      ),
    );
  }
}
