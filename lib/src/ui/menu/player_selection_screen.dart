import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/models/player_data.dart';
import 'package:shieldbound/src/providers/provider.dart';
import 'package:shieldbound/src/services/pocketbase_service.dart';
import 'package:shieldbound/src/ui/game_wrapper.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import 'package:shieldbound/src/ui/menu/character_selection_screen.dart';

class PlayerSelectionScreen extends ConsumerStatefulWidget {
  const PlayerSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PlayerSelectionScreen> createState() =>
      _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends ConsumerState<PlayerSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;
  List<PlayerData> _existingPlayers = [];
  String? _errorMessage;

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

    // Load existing players when the screen initializes
    _loadExistingPlayers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPlayers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final pocketBaseService = ref.read(pocketbaseServiceProvider);
      // Get all players from the database
      final players = await pocketBaseService.getAllPlayers();

      setState(() {
        _existingPlayers = players;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load players: $e";
        _isLoading = false;
      });
    }
  }

  void _onCreateNewPlayer() {
    // Navigate to character selection screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CharacterSelectionScreen(),
      ),
    );
  }

  void _onSelectPlayer(PlayerData player) {
    // Select this player and navigate to the game
    ref.read(playerDataProvider.notifier).state = player;
    ref.read(currentPlayerIdProvider.notifier).state = player.id;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size * 0.5;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with gradient overlay
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

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animation),
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/UI/Ribbons/Ribbon_Blue_3Slides.png',
                            width: screenSize.width * 0.38,
                          ),
                          Text(
                            'SELECT PLAYER',
                            style: TextStyle(
                              fontFamily: 'MedievalSharp',
                              fontSize: screenSize.width * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // SizedBox(height: 10),

                      // Create New Player Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ImageButton(
                          imagePath:
                              'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                          pressedImagePath:
                              'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                          text: 'New Player',
                          width: screenSize.width * 0.28,
                          onPressed: _onCreateNewPlayer,
                        ),
                      ),

                      // SizedBox(height: 10),

                      // Existing Players Header
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'OR CONTINUE WITH EXISTING PLAYER',
                          style: TextStyle(
                            fontFamily: 'MedievalSharp',
                            fontSize: screenSize.width * 0.025,
                            color: Colors.amber,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Error Message Display
                      if (_errorMessage != null)
                        Container(
                          margin:
                              EdgeInsets.only(bottom: screenSize.height * 0.02),
                          padding: EdgeInsets.all(screenSize.width * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontFamily: 'MedievalSharp',
                              fontSize: screenSize.width * 0.03,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Loading Indicator or Player List
                      Expanded(
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: Colors.amber))
                            : _existingPlayers.isEmpty
                                ? Center(
                                    child: Text(
                                      'No existing players found',
                                      style: TextStyle(
                                        fontFamily: 'MedievalSharp',
                                        fontSize: screenSize.width * 0.035,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _existingPlayers.length,
                                    itemBuilder: (context, index) {
                                      final player = _existingPlayers[index];
                                      return _buildPlayerCard(context, player);
                                    },
                                  ),
                      ),

                      // Back Button
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ImageButton(
                          imagePath:
                              'assets/images/UI/Buttons/Button_Red_3Slides.png',
                          pressedImagePath:
                              'assets/images/UI/Buttons/Button_Red_3Slides_Pressed.png',
                          text: 'Back',
                          width: screenSize.width * 0.25,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, PlayerData player) {
    // Determine the icon based on character class
    IconData characterIcon = Icons.person;
    Color characterColor = Colors.blue;

    if (player.character == 'Wizard') {
      characterIcon = Icons.auto_fix_high;
      characterColor = Colors.purple;
    } else if (player.character == 'Soldier') {
      characterIcon = Icons.shield;
      characterColor = Colors.red;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Giảm thêm
      color: Colors.blue.shade900.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Giảm thêm
        side: BorderSide(color: Colors.blue.shade200, width: 1),
      ),
      child: InkWell(
        onTap: () => _onSelectPlayer(player),
        borderRadius: BorderRadius.circular(8), // Giảm thêm
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8.0, vertical: 6.0), // Giảm thêm
          child: Row(
            children: [
              // Character Icon - thu gọn hơn
              Container(
                width: 32, // Thu nhỏ hơn nữa
                height: 32, // Thu nhỏ hơn nữa
                decoration: BoxDecoration(
                  color: characterColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  characterIcon,
                  color: characterColor,
                  size: 18, // Thu nhỏ hơn nữa
                ),
              ),
              SizedBox(width: 8), // Thu nhỏ
              // Player Info - kết hợp thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Thêm để thu gọn khoảng cách
                  children: [
                    Row(
                      children: [
                        Text(
                          player.name,
                          style: TextStyle(
                            fontFamily: 'MedievalSharp',
                            fontSize: 14, // Giảm thêm
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(${player.character})',
                          style: TextStyle(
                            fontFamily: 'MedievalSharp',
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    // Thông tin HP và Gold trên cùng 1 dòng
                    Text(
                      'HP: ${player.health.toInt()}/${player.maxHealth.toInt()} • Gold: ${player.gold}',
                      style: TextStyle(
                        fontFamily: 'MedievalSharp',
                        fontSize: 11, // Thu nhỏ hơn nữa
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.amber,
                size: 12, // Thu nhỏ
              ),
            ],
          ),
        ),
      ),
    );
  }
}
