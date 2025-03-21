import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/models/player_data.dart';
import 'package:shieldbound/src/providers/provider.dart';
import 'package:shieldbound/src/services/pocketbase_service.dart';
import 'package:shieldbound/src/ui/game_wrapper.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';

class CharacterSelectionScreen extends ConsumerStatefulWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState
    extends ConsumerState<CharacterSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _selectedCharacter = 'Soldier'; // Default selected character
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;
  String? _errorMessage;
  bool _isNameValid = false;

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

    // Listen to text changes to validate name
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateName() {
    final name = _nameController.text.trim();
    setState(() {
      _isNameValid = name.length >= 3 && name.length <= 20;
    });
  }

  Future<void> _createPlayer() async {
    if (_isCreating) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a character name";
      });
      return;
    }

    if (!_isNameValid) {
      setState(() {
        _errorMessage = "Name must be between 3-20 characters";
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      // Create new player data based on selected character
      final newPlayer = PlayerData(
        id: '', // ID will be assigned by PocketBase
        name: name, // Add the name field
        character: _selectedCharacter,
        health: _selectedCharacter == 'Soldier' ? 150 : 100,
        maxHealth: _selectedCharacter == 'Soldier' ? 150 : 100,
        damage: _selectedCharacter == 'Soldier' ? 20 : 30,
        moveSpeed: _selectedCharacter == 'Soldier' ? 100 : 80,
        gold: 100, // Starting gold
      );

      // Save to PocketBase
      final pocketBaseService = ref.read(pocketbaseServiceProvider);
      final createdPlayer = await pocketBaseService.createPlayer(newPlayer);

      if (createdPlayer != null) {
        // Update providers with new player data
        ref.read(playerDataProvider.notifier).state = createdPlayer;
        ref.read(currentPlayerIdProvider.notifier).state = createdPlayer.id;

        // Navigate to game
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GameWrapper()),
          );
        }
      } else {
        setState(() {
          _errorMessage = "Failed to create player. Please try again.";
          _isCreating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isCreating = false;
      });
    }
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
                            width: screenSize.width *
                                0.35, // Giảm từ 0.5 xuống 0.35
                          ),
                          Text(
                            'CHOOSE HERO', // Rút gọn "CHOOSE YOUR HERO"
                            style: TextStyle(
                              fontFamily: 'MedievalSharp',
                              fontSize:
                                  screenSize.width * 0.03, // Giảm kích thước
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    color: Colors.black,
                                    offset: const Offset(1, 1),
                                    blurRadius: 3)
                              ],
                            ),
                          ),
                        ],
                      ),

                      // SizedBox(height: 20),

                      // Character Name Input
                      Container(
                        width: screenSize.width, // Giảm từ 0.6 xuống 0.5
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4), // Giảm padding
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900.withOpacity(0.6),
                          borderRadius:
                              BorderRadius.circular(8), // Giảm từ 10 xuống 8
                          border: Border.all(
                            color: _isNameValid
                                ? Colors.green
                                : _nameController.text.isEmpty
                                    ? Colors.blue.shade200
                                    : Colors.red,
                            width: 1, // Giảm từ 2 xuống 1
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hero Name',
                              style: TextStyle(
                                fontFamily: 'MedievalSharp',
                                fontSize: 14, // Giảm từ 16 xuống 14
                                color: Colors.white,
                              ),
                            ),
                            TextField(
                              controller: _nameController,
                              style: TextStyle(
                                fontFamily: 'MedievalSharp',
                                fontSize: 16, // Giảm từ 18 xuống 16
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter name...', // Rút gọn text
                                hintStyle: TextStyle(
                                  fontFamily: 'MedievalSharp',
                                  fontSize: 14, // Giảm từ 16 xuống 14
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 4), // Giảm từ 8 xuống 4
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20)
                              ],
                            ),
                            if (_nameController.text.isNotEmpty &&
                                !_isNameValid)
                              Text(
                                'Name: 3-20 chars', // Rút gọn thông báo
                                style: TextStyle(
                                  fontFamily: 'MedievalSharp',
                                  fontSize: 10, // Giảm từ 12 xuống 10
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Error Message Display
                      if (_errorMessage != null)
                        Container(
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          padding: EdgeInsets.all(8),
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

                      // Character Selection Cards
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Soldier Card
                              Expanded(
                                child: _buildCharacterCard(
                                  context,
                                  'Soldier',
                                  'A strong warrior with high health and balanced stats.',
                                  Icons.shield,
                                  Colors.red,
                                  {'Health': 150, 'Damage': 20, 'Speed': 100},
                                ),
                              ),

                              // SizedBox(width: 20),

                              // Wizard Card
                              Expanded(
                                child: _buildCharacterCard(
                                  context,
                                  'Wizard',
                                  'A powerful spellcaster with high damage but lower health.',
                                  Icons.auto_fix_high,
                                  Colors.purple,
                                  {'Health': 100, 'Damage': 30, 'Speed': 80},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Create Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0), // Giảm từ 8 xuống 6
                        child: ImageButton(
                          imagePath:
                              'assets/images/UI/Buttons/Button_Blue_3Slides.png',
                          pressedImagePath:
                              'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
                          text: 'Create', // Rút gọn từ "Create Character"
                          width:
                              screenSize.width * 0.3, // Giảm từ 0.4 xuống 0.3
                          onPressed: (_isNameValid && !_isCreating)
                              ? () => _createPlayer()
                              : () {
                                  if (!_isNameValid) {
                                    setState(() {
                                      _errorMessage =
                                          "Name must be 3-20 characters";
                                    });
                                  }
                                },
                        ),
                      ),

                      if (_isCreating)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),

                      // Back Button
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ImageButton(
                          imagePath:
                              'assets/images/UI/Buttons/Button_Red_3Slides.png',
                          pressedImagePath:
                              'assets/images/UI/Buttons/Button_Red_3Slides_Pressed.png',
                          text: 'Back',
                          width: screenSize.width * 0.25,
                          onPressed: () {
                            if (!_isCreating) {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            }
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

  Widget _buildCharacterCard(
    BuildContext context,
    String characterName,
    String description,
    IconData icon,
    Color color,
    Map<String, int> stats,
  ) {
    final isSelected = _selectedCharacter == characterName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacter = characterName;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.blue.shade900.withOpacity(isSelected ? 0.8 : 0.5),
          borderRadius: BorderRadius.circular(12), // Giảm từ 16 xuống 12
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.blue.shade200,
            width: isSelected ? 2 : 1, // Giảm thickness
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1)
                ] // Giảm kích thước shadow
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0), // Giảm từ 16 xuống 12
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Character Icon
              Container(
                width: 20, // Giảm từ 70 xuống 50
                height: 20, // Giảm từ 70 xuống 50
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.amber : color,
                    width: 1, // Giảm từ 2 xuống 1
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.amber : color,
                  size: 15, // Giảm từ 40 xuống 30
                ),
              ),
              // SizedBox(height: 8), // Giảm từ 16 xuống 8

              // Character Name
              Text(
                characterName,
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: 10, // Giảm từ 24 xuống 20
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.amber : Colors.white,
                ),
              ),
              // SizedBox(height: 4), // Giảm từ 8 xuống 4

              // Description - thu gọn lại
              Text(
                description.length > 50
                    ? description.substring(0, 50) + '...'
                    : description,
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: 8, // Giảm từ 14 xuống 12
                  color: Colors.grey.shade300,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Giới hạn số dòng
                overflow: TextOverflow.ellipsis,
              ),
              // SizedBox(height: 8), // Giảm từ 16 xuống 8

              // Stats - thu gọn lại
              ...stats.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0), // Giảm từ 4 xuống 2
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontFamily: 'MedievalSharp',
                            fontSize: 10, // Giảm từ 16 xuống 14
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontFamily: 'MedievalSharp',
                            fontSize: 10, // Giảm từ 16 xuống 14
                            color: isSelected ? Colors.amber : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),

              // Selected Indicator - thu nhỏ lại
              if (isSelected)
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0), // Giảm từ 16 xuống 8
                  child: Text(
                    'SELECTED',
                    style: TextStyle(
                      fontFamily: 'MedievalSharp',
                      fontSize: 9, // Giảm từ 14 xuống 12
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
