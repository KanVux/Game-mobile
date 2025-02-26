import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import '../../../shieldbound.dart'; // Import the new ImageButton

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/UI/Ribbons/Ribbon_Blue_3Slides.png',
                      width: 450,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      top: 35,
                      child: Text(
                        'SHIELDBOUND',
                        style: TextStyle(
                          fontFamily: 'MedievalSharp',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
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
                      PageRouteBuilder(
                        transitionDuration: Duration(seconds: 4),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Stack(
                            children: [
                              GameWidget(game: Shieldbound()),
                              FadeTransition(
                                opacity: Tween<double>(begin: 1, end: 0)
                                    .animate(animation),
                                child: Container(color: Colors.black),
                              ),
                            ],
                          );
                        },
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
                    // Settings functionality
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
