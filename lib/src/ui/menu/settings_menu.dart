import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/providers/provider.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import 'package:shieldbound/src/ui/menu/progress_bar.dart';
import 'main_menu.dart';

class SettingsMenu extends ConsumerStatefulWidget {
  final bool fromPause; // Nếu true, mở từ pause menu
  const SettingsMenu({Key? key, this.fromPause = false}) : super(key: key);

  @override
  ConsumerState<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends ConsumerState<SettingsMenu>
    with SingleTickerProviderStateMixin {
  bool isMuted = false;
  double musicVolume = 0.5;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );
    _animationController.forward();
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final audioService = ref.read(audioServiceProvider);
    setState(() {
      musicVolume = audioService.volume;
      isMuted = audioService.isMuted;
    });
  }

  /// Toggle mute sử dụng FlameAudio qua AudioService
  void _toggleMute() {
    final audioService = ref.read(audioServiceProvider);
    audioService.toggleMute().then((_) {
      setState(() {
        isMuted = audioService.isMuted;
        musicVolume = audioService.volume;
      });
    });
  }

  /// Adjust volume và cập nhật AudioService ngay lập tức
  void _adjustVolume(double delta) {
    final audioService = ref.read(audioServiceProvider);
    final newVolume = (musicVolume + delta).clamp(0.0, 1.0);
    audioService.setVolume(newVolume).then((_) {
      setState(() {
        musicVolume = newVolume;
        isMuted = newVolume == 0.0;
      });
    });
  }

  /// Khi nhấn nút Back, nếu Settings mở từ Pause Menu thì pop trở về Pause Menu, ngược lại chuyển về MainMenu
  void _onBackPressed(BuildContext context) {
    _animationController.reverse().then((_) {
      if (widget.fromPause) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MainMenu(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
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
          // Background Image với gradient overlay
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ).createShader(rect),
              blendMode: BlendMode.darken,
              child: Image.asset(
                'assets/images/UI/Background/menu_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Hiệu ứng ánh sáng
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
          // Đường viền trang trí
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
          // Settings UI
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
                    maxWidth: 600,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Biểu tượng Settings
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
                        // Title
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
                        // Mute Button
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
                        // Volume Control
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
                        // Volume Control Bar
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
                        // Back Button - chuyển về Main Menu
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
                              _onBackPressed(context);
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
