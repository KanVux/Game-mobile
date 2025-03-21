import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game_wrapper.dart';
import 'player_selection_screen.dart';
import 'settings_menu.dart';
import 'dart:math' as math;

import 'shop_menu.dart';

class MainMenu extends StatefulWidget{
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late final AnimationController _titleAnimationController;
  late final AnimationController _buttonAnimationController;
  late final Animation<double> _titleScaleAnimation;
  late final Animation<double> _titleGlowAnimation;
  bool _showCredits = false;

  @override
  void initState() {
    super.initState();
    // Title animation setup
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _titleScaleAnimation = Tween<double>(begin: 0.6, end: 0.7).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _titleGlowAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Button animation setup
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated Background with parallax effect
            const ParallaxBackground(),

            // Main Content
            _showCredits
                ? _buildCreditsScreen()
                : _buildMainMenuContent(screenSize),

            // Decorative elements
            _buildDecorativeElements(screenSize),

            // Version information
            Positioned(
              bottom: 10,
              right: 10,
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuContent(Size screenSize) {
    // Calculate adaptive sizing
    final double titleScale = screenSize.width < 400 ? 0.8 : 1.0;
    final double buttonWidth =
        screenSize.width * 0.6 > 250 ? 250 : screenSize.width * 0.6;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game Title with animation
            AnimatedBuilder(
              animation: _titleAnimationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect
                    Container(
                      width: 270 * titleScale,
                      height: 80 * titleScale,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue
                                .withValues(alpha: _titleGlowAnimation.value),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Title banner
                    Transform.scale(
                      scale: _titleScaleAnimation.value * titleScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/UI/Ribbons/Ribbon_Blue_3Slides.png',
                            width: 450 * titleScale,
                            height: 120 * titleScale,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: 30 * titleScale,
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.blue.shade200,
                                    Colors.white,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                  tileMode: TileMode.mirror,
                                  transform: GradientRotation(
                                      _titleAnimationController.value *
                                          math.pi *
                                          2),
                                ).createShader(bounds);
                              },
                              child: Text(
                                'SHIELDBOUND',
                                style: TextStyle(
                                  fontFamily: 'MedievalSharp',
                                  fontSize: 30 * titleScale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Menu Buttons with staggered animation
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: buttonWidth,
                child: Column(
                  children: _buildAnimatedButtons(buttonWidth),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedButtons(double buttonWidth) {
    final buttonItems = [
      {
        'text': 'Start Game',
        'onPressed': () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(
                  opacity: animation,
                  child: PlayerSelectionScreen(),
                );
              },
            ),
          );
        },
      },
      {
        'text': 'Shop',
        'onPressed': () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(
                  opacity: animation,
                  child: ShopMenu(),
                );
              },
            ),
          );
        },
      },
      {
        'text': 'Settings',
        'onPressed': () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(
                  opacity: animation,
                  child: SettingsMenu(),
                );
              },
            ),
          );
        },
      },
      {
        'text': 'Credits',
        'onPressed': () {
          HapticFeedback.lightImpact();
          setState(() {
            _showCredits = true;
          });
        },
      },
      {
        'text': 'Exit',
        'onPressed': () {
          HapticFeedback.lightImpact();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.blue.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.blue.shade300, width: 2),
              ),
              title: const Text(
                'Exit Game?',
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  color: Colors.white,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              content: const Text(
                'Are you sure you want to exit the game?',
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'MedievalSharp',
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Exit',
                        style: TextStyle(
                          fontFamily: 'MedievalSharp',
                          color: Colors.red.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).then((value) {
            if (value == true) {
              exit(0); // Chỉ có hiệu lực ở Windows sửa lại sau
            }
          });
        },
      },
    ];

    List<Widget> result = [];

    for (int i = 0; i < buttonItems.length; i++) {
      final item = buttonItems[i];

      final buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _buttonAnimationController,
          curve: Interval(
            i * 0.2, // Stagger the animations
            0.2 + i * 0.2,
            curve: Curves.easeOut,
          ),
        ),
      );

      result.add(
        AnimatedBuilder(
          animation: buttonAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  buttonAnimation.value * 0 - (1 - buttonAnimation.value) * 100,
                  0),
              child: Opacity(
                opacity: buttonAnimation.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EnhancedImageButton(
                    imagePath:
                        'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                    pressedImagePath:
                        'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                    text: item['text'] as String,
                    onPressed: item['onPressed'] as Function(),
                    width: buttonWidth,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return result;
  }

  Widget _buildDecorativeElements(Size screenSize) {
    // Only show decorations on larger screens
    if (screenSize.width < 400) return const SizedBox.shrink();

    return Stack(
      children: [
        // Top left shield decoration
        Positioned(
          top: 20,
          left: 20,
          child: Image.asset(
            'assets/images/UI/Settings/shield_icon.png',
            width: 60,
            height: 60,
          ),
        ),

        // Top right shield decoration
        Positioned(
          top: 20,
          right: 20,
          child: Image.asset(
            'assets/images/UI/Settings/shield_icon.png',
            width: 60,
            height: 60,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsScreen() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Nút đóng ở góc trên bên phải
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _showCredits = false;
                    });
                  },
                ),
              ),
            ),

            // Sử dụng Expanded để phần nội dung có thể co giãn
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CREDITS',
                          style: TextStyle(
                            fontFamily: 'MedievalSharp',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        _creditItem('Game Design', 'Khang Vu & Nhat Minh'),
                        _creditItem('Art & Animation', 'Khang Vu & Nhat Minh'),
                        _creditItem('Programming', 'Khang Vu & Nhat Minh'),
                        _creditItem('Music & Sound', 'Khang Vu & Nhat Minh'),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Nút Back ở cuối màn hình
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: EnhancedImageButton(
                imagePath: 'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                pressedImagePath:
                    'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                text: 'Back',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _showCredits = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _creditItem(String role, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(
            role,
            style: TextStyle(
              fontFamily: 'MedievalSharp',
              fontSize: 18,
              color: Colors.blue.shade300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'MedievalSharp',
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced button with hover effects
class EnhancedImageButton extends StatefulWidget {
  final String imagePath;
  final String pressedImagePath;
  final String text;
  final Function onPressed;
  final double width;

  const EnhancedImageButton({
    super.key,
    required this.imagePath,
    required this.pressedImagePath,
    required this.text,
    required this.onPressed,
    this.width = 250,
  });

  @override
  _EnhancedImageButtonState createState() => _EnhancedImageButtonState();
}

class _EnhancedImageButtonState extends State<EnhancedImageButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate height proportionally based on width
    final double aspectRatio = 250 / 60; // Original width/height ratio
    final double height = widget.width / aspectRatio;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _hoverController.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _hoverController.reverse();
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
          widget.onPressed();
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.95 : _scaleAnimation.value,
              child: SizedBox(
                width: widget.width,
                height: height,
                child: Stack(
                  alignment: Alignment(0, -0.5),
                  children: [
                    // Button background
                    Image.asset(
                      _isPressed ? widget.pressedImagePath : widget.imagePath,
                      fit: BoxFit.contain,
                      width: widget.width,
                    ),

                    // Glow effect when hovered
                    if (_isHovered && !_isPressed)
                      Container(
                        width: widget.width,
                        height: height,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),

                    // Button text
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            fontFamily: 'MedievalSharp',
                            fontSize: 20 *
                                (widget.width /
                                    250), // Scale font size proportionally
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Parallax background effect
class ParallaxBackground extends StatefulWidget {
  const ParallaxBackground({super.key}) : super();

  @override
  _ParallaxBackgroundState createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(minutes: 3),
      vsync: this,
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Positioned.fill(
          child: Image.asset(
            'assets/images/UI/Background/menu_background.png',
            fit: BoxFit.cover,
          ),
        ),

        // Floating particles effect
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: ParticlesPainter(_controller.value),
            );
          },
        ),
      ],
    );
  }
}

// Particle effect painter
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final int particleCount = 50;
  final List<Offset> particlePositions = [];
  final List<double> particleSizes = [];
  final List<double> particleSpeeds = [];
  final math.Random random =
      math.Random(42); // Fixed seed for deterministic behavior

  ParticlesPainter(this.animationValue) {
    if (particlePositions.isEmpty) {
      for (int i = 0; i < particleCount; i++) {
        particlePositions.add(
          Offset(
            random.nextDouble() * 1.2 -
                0.1, // x position (slightly beyond screen)
            random.nextDouble(), // y position
          ),
        );
        particleSizes.add(random.nextDouble() * 3 + 1); // Size between 1-4
        particleSpeeds.add(random.nextDouble() * 0.2 + 0.05); // Speed
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      // Calculate particle position based on animation
      double xPos =
          (particlePositions[i].dx + animationValue * particleSpeeds[i]) % 1.2;
      double yPos = particlePositions[i].dy;

      // Draw the particle
      canvas.drawCircle(
        Offset(xPos * size.width, yPos * size.height),
        particleSizes[i],
        paint
          ..color = Colors.white.withValues(alpha: 0.2 + random.nextDouble() * 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}
