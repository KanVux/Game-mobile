import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import 'package:shieldbound/src/ui/menu/settings_menu.dart';
import '../../../shieldbound.dart';// Import the new ImageButton

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/UI/Background/menu_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Menu Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ShieldBound RPG',
                  style: TextStyle(
                    fontFamily: 'MedievalSharp',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                // Start Game Button
                ImageButton(
                  imagePath: 'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                  pressedImagePath:
                      'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                  text: 'Start Game',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameWidget(game: Shieldbound()),
                      ),
                    );
                  },
                ),

                SizedBox(height: 10),

                // Settings Button
                ImageButton(
                  imagePath: 'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                  pressedImagePath:
                      'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                  text: 'Settings',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SettingsMenu()), // Navigate to Settings
                    );
                  },
                ),

                SizedBox(height: 10),

                // Exit Button
                ImageButton(
                  imagePath: 'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                  pressedImagePath:
                      'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                  text: 'Exit',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
