import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import 'package:shieldbound/src/ui/menu/progress_bar.dart';
import 'main_menu.dart'; // Import Main Menu for navigation

class SettingsMenu extends StatefulWidget {
  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  // bool isSoundOn = true;
  bool isMuted = false;
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
      musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      isMuted = musicVolume == 0.0;
    });
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.setBool('soundOn', isMuted);
    // prefs.setDouble('musicVolume', musicVolume);
    prefs.setDouble('musicVolume', musicVolume);
  }

  /// Toggle Mute
  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      musicVolume = isMuted ? 0.0 : 1.0; // 🔥 Mute = 0, Unmute = max
      _saveSettings();
    });
  }

  /// Adjust Volume
  void _adjustVolume(double delta) {
    setState(() {
      musicVolume = (musicVolume + delta).clamp(0.0, 1.0);
      isMuted = musicVolume == 0.0; // 🔥 Auto-mute if volume reaches 0
      _saveSettings();
    });
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
                Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white54, // Background color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ImageButton(
                    imagePath: isMuted
                        ? 'assets/images/UI/Icons/Disable_03.png' // Mute icon
                        : 'assets/images/UI/Icons/Regular_03.png', // Sound on icon
                    pressedImagePath: isMuted
                        ? 'assets/images/UI/Icons/Disable_03.png' // Mute pressed
                        : 'assets/images/UI/Icons/Regular_03.png', // Sound on pressed
                    width: 60,
                    onPressed: _toggleMute,
                  ),
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
                SizedBox(height: 10),

// Container chứa cả thanh tiến trình và các nút điều chỉnh
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    children: [
                      // tăng âm lượng
                      Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ImageButton(
                          imagePath: 'assets/images/UI/Icons/Regular_09.png',
                          pressedImagePath:
                              'assets/images/UI/Icons/Pressed_09.png',
                          width: 60,
                          onPressed: () => _adjustVolume(-0.1),
                        ),
                      ),
                      // Thanh tiến trình
                      Expanded(
                        child: ProgressBar(
                          value: musicVolume * 100,
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 30,
                          segments: 10,
                        ),
                      ),

                      // Nút tăng âm lượng
                      Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ImageButton(
                          imagePath: 'assets/images/UI/Icons/Regular_08.png',
                          pressedImagePath:
                              'assets/images/UI/Icons/Pressed_08.png',
                          width: 60,
                          onPressed: () => _adjustVolume(0.1),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${(musicVolume * 100).round()}%',
                  style: TextStyle(
                    fontFamily: 'MedievalSharp',
                    fontSize: 16,
                    color: Colors.white,
                  ),
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
