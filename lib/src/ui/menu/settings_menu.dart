import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import 'main_menu.dart'; // Import Main Menu for navigation


class SettingsMenu extends StatefulWidget {
  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  bool isSoundOn = true;
  double musicVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSoundOn = prefs.getBool('soundOn') ?? true;
      musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    });
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('soundOn', isSoundOn);
    prefs.setDouble('musicVolume', musicVolume);
  }

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

          // Settings UI
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'MedievalSharp',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                // Sound Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sound: ',
                      style: TextStyle(
                        fontFamily: 'MedievalSharp',
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    Switch(
                      value: isSoundOn,
                      onChanged: (value) {
                        setState(() {
                          isSoundOn = value;
                          _saveSettings();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Volume: ',
                  style: TextStyle(
                    fontFamily: 'MedievalSharp',
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Slider(
                  value: musicVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10, // Adjust for smoothness
                  onChanged: (value) {
                    setState(() {
                      musicVolume = value;
                      _saveSettings();
                    });
                  },
                ),
                SizedBox(height: 20),
                ImageButton(
                  imagePath: 'assets/images/UI/Buttons/Button_Red_3Slides.png',
                  pressedImagePath:
                      'assets/images/UI/Buttons/Button_Red_3Slides_Pressed.png',
                  text: 'Back',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                    );
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
