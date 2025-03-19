import 'package:flutter/material.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import 'package:shieldbound/src/ui/menu/progress_bar.dart';
import 'main_menu.dart';

class SettingsMenu extends StatefulWidget {
  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu>
    with SingleTickerProviderStateMixin {
  bool isMuted = false;
  double musicVolume = 0.5;
  late AnimationController _animationController;
  late Animation<double> _animation;
  // final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Thêm animation cho các phần tử
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    // setState(() {
    //   musicVolume = _audioService.volume;
    //   isMuted = _audioService.isMuted;
    // });
  }

  /// Save settings to SharedPreferences
  // Future<void> _saveSettings() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setDouble('musicVolume', musicVolume);
  // }

  /// Toggle Mute
  void _toggleMute() {
    // _audioService.toggleMute();
    // setState(() {
    //   isMuted = _audioService.isMuted;
    //   musicVolume = _audioService.volume;
    // });
  }

  /// Adjust Volume
  void _adjustVolume(double delta) {
    final newVolume = (musicVolume + delta).clamp(0.0, 1.0);
    // _audioService.setVolume(newVolume);
    // setState(() {
    //   musicVolume = newVolume;
    //   isMuted = newVolume == 0.0;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.height * 0.06; // 6% chiều cao màn hình
    final titleFontSize = screenSize.height * 0.04; // 4% chiều cao
    final buttonFontSize = screenSize.height * 0.025; // 2.5% chiều cao

    return Scaffold(
      body: Stack(
        children: [
          // Background Image với hiệu ứng gradient overlay (giữ nguyên)
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9)
                ],
              ).createShader(rect),
              blendMode: BlendMode.darken,
              child: Image.asset(
                'assets/images/UI/Background/menu_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Hiệu ứng ánh sáng (điều chỉnh kích thước động)
          Positioned(
            top: -screenSize.height * 0.15,
            left: screenSize.width / 2 - screenSize.width * 0.15,
            child: Container(
              width: screenSize.width * 0.3,
              height: screenSize.width * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.2),
                    blurRadius: screenSize.width * 0.2,
                    spreadRadius: screenSize.width * 0.1,
                  ),
                ],
              ),
            ),
          ),

          // Đường viền trang trí (sử dụng tỷ lệ %)
          Positioned(
            top: screenSize.height * 0.02,
            left: screenSize.width * 0.03,
            right: screenSize.width * 0.03,
            bottom: screenSize.height * 0.02,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1 + screenSize.width * 0.002,
                ),
                borderRadius: BorderRadius.circular(screenSize.width * 0.04),
              ),
            ),
          ),

          // Settings UI (phần chính)
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animation),
                child: Container(
                  width: screenSize.width * 0.85,
                  constraints: BoxConstraints(
                    maxWidth: 600, // Giới hạn kích thước tối đa
                    maxHeight: screenSize.height * 0.9,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.03,
                    horizontal: screenSize.width * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius:
                        BorderRadius.circular(screenSize.width * 0.05),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.5),
                      width: 1 + screenSize.width * 0.002,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.1),
                        blurRadius: screenSize.width * 0.05,
                        spreadRadius: screenSize.width * 0.02,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    // Thêm scroll nếu nội dung dài
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Biểu tượng Settings (kích thước động)
                        Container(
                          padding: EdgeInsets.all(screenSize.width * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Colors.amber,
                            size: iconSize,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),

                        // Title (kích thước chữ động)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'SETTINGS',
                              style: TextStyle(
                                fontFamily: 'MedievalSharp',
                                fontSize: titleFontSize * 1.2,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = Colors.black.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'SETTINGS',
                              style: TextStyle(
                                fontFamily: 'MedievalSharp',
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                                shadows: [
                                  Shadow(
                                    color: Colors.amber.withOpacity(0.5),
                                    offset: Offset(0, 0),
                                    blurRadius: screenSize.width * 0.03,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.03),

                        // Mute Button (kích thước động)
                        _buildSettingItem(
                          context,
                          label: 'Game Sound',
                          child: Container(
                            padding: EdgeInsets.all(screenSize.width * 0.005),
                            decoration: BoxDecoration(
                              color: isMuted
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.green.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(
                                  screenSize.width * 0.01),
                            ),
                            child: ImageButton(
                              imagePath: isMuted
                                  ? 'assets/images/UI/Icons/Disable_03.png'
                                  : 'assets/images/UI/Icons/Regular_03.png',
                              pressedImagePath: isMuted
                                  ? 'assets/images/UI/Icons/Disable_03.png'
                                  : 'assets/images/UI/Icons/Regular_03.png',
                              width: screenSize.width * 0.05,
                              onPressed: _toggleMute,
                            ),
                          ),
                        ),

                        // Volume Control (kích thước động)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.02),
                          child: _buildSettingItem(
                            context,
                            label: 'Volume Control',
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.03),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    screenSize.width * 0.02),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${(musicVolume * 100).round()}%',
                                style: TextStyle(
                                  fontFamily: 'MedievalSharp',
                                  fontSize: buttonFontSize * 1.2,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Volume Control Bar (sử dụng LayoutBuilder)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              children: [
                                // Giảm âm lượng
                                Container(
                                  padding:
                                      EdgeInsets.all(screenSize.width * 0.0005),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                        screenSize.width * 0.01),
                                  ),
                                  child: ImageButton(
                                    imagePath:
                                        'assets/images/UI/Icons/Regular_09.png',
                                    pressedImagePath:
                                        'assets/images/UI/Icons/Pressed_09.png',
                                    width: constraints.maxWidth * 0.08,
                                    onPressed: () => _adjustVolume(-0.1),
                                  ),
                                ),

                                // Thanh tiến trình
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenSize.width * 0.03),
                                    child: ProgressBar(
                                      value: musicVolume * 100,
                                      height: screenSize.height * 0.05,
                                      segments: 10,
                                    ),
                                  ),
                                ),

                                // Tăng âm lượng
                                Container(
                                  padding:
                                      EdgeInsets.all(screenSize.width * 0.0005),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                        screenSize.width * 0.01),
                                  ),
                                  child: ImageButton(
                                    imagePath:
                                        'assets/images/UI/Icons/Regular_08.png',
                                    pressedImagePath:
                                        'assets/images/UI/Icons/Pressed_08.png',
                                    width: constraints.maxWidth * 0.08,
                                    onPressed: () => _adjustVolume(0.1),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: screenSize.height * 0.04),

                        // Back Button (kích thước động)
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: screenSize.width * 0.003,
                                spreadRadius: screenSize.width * 0.001,
                              ),
                            ],
                          ),
                          child: ImageButton(
                            imagePath:
                                'assets/images/UI/Buttons/Button_Red_3Slides.png',
                            pressedImagePath:
                                'assets/images/UI/Buttons/Button_Red_3Slides_Pressed.png',
                            text: 'BACK TO MENU',
                            width: screenSize.width * 0.18,
                            onPressed: () {
                              _animationController.reverse().then((value) {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        MainMenu(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        Duration(milliseconds: 500),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Widget phụ trợ cho các item cài đặt
  Widget _buildSettingItem(BuildContext context,
      {required String label, required Widget child}) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.02),
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.015,
        horizontal: screenSize.width * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'MedievalSharp',
              fontSize: screenSize.height * 0.04,
              color: Colors.white,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
