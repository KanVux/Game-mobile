import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import 'package:shieldbound/src/ui/menu/settings_menu.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResumePressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onMainMenuPressed;

  const PauseMenu({
    Key? key,
    required this.onResumePressed,
    required this.onSettingsPressed,
    required this.onMainMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double buttonWidth =
        screenSize.width * 0.4 > 200 ? 200 : screenSize.width * 0.4;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: screenSize.width * 0.7,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade900.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blue.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PAUSED',
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Resume Button
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ImageButton(
                  imagePath: 'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                  pressedImagePath:
                      'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                  text: 'Resume',
                  width: buttonWidth,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onResumePressed();
                  },
                ),
              ),

              // Settings Button
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ImageButton(
                  imagePath: 'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                  pressedImagePath:
                      'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                  text: 'Settings',
                  width: buttonWidth,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SettingsMenu(fromPause: true),
                      ),
                    );
                  },
                ),
              ),

              // Main Menu Button
              ImageButton(
                imagePath: 'assets/images/UI/Buttons/Button_Red_3Slides.png',
                pressedImagePath:
                    'assets/images/UI/Buttons/Button_Red_3Slides_Pressed.png',
                text: 'Main Menu',
                width: buttonWidth,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onMainMenuPressed();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
