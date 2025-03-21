import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/models/shop_item.dart';
import 'package:shieldbound/src/models/player_data.dart';
import 'package:shieldbound/src/providers/provider.dart';
import 'package:shieldbound/src/services/pocketbase_service.dart';
import 'package:shieldbound/src/ui/menu/image_button.dart';
import '../hud_overlay.dart';
import 'main_menu.dart';

class ShopMenu extends ConsumerStatefulWidget {
  final bool fromPause; // If true, opened from pause menu
  const ShopMenu({Key? key, this.fromPause = false}) : super(key: key);

  @override
  ConsumerState<ShopMenu> createState() => _ShopMenuState();
}

class _ShopMenuState extends ConsumerState<ShopMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  ShopItem? _selectedItem;
  bool _isLoading = false;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  Future<void> _purchaseItem(ShopItem item, PlayerData playerData) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if player has enough gold
      if (playerData.gold < item.price) {
        setState(() {
          _errorMessage = "Not enough gold to purchase this item!";
          _isLoading = false;
        });
        return;
      }

      // Apply item effects to player
      playerData.gold -= item.price;

      if (item.isTrophy) {
        // Player wins the game!
        setState(() {
          _isLoading = false;
        });
        // Show victory dialog
        _showVictoryDialog();
        return;
      }

      // Apply stat boost based on what the item affects
      switch (item.affects) {
        case 'health':
          playerData.maxHealth += item.increaseAmount;
          playerData.health += item.increaseAmount;
          break;
        case 'damage':
          playerData.damage += item.increaseAmount;
          ref.read(playerDamageProvider.notifier).state =
              playerData.damage.toInt();
          break;
        case 'moveSpeed':
          playerData.moveSpeed += item.increaseAmount;
          break;
      }

      // Save updated player data to PocketBase
      final pocketBaseService = ref.read(pocketbaseServiceProvider);
      final updatedPlayerData =
          await pocketBaseService.updatePlayer(playerData);

      if (updatedPlayerData != null) {
        // Update player data in state
        ref.read(playerDataProvider.notifier).state = updatedPlayerData;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully purchased ${item.name}!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = "Failed to update player data. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.amber, width: 3),
        ),
        title: const Text(
          'VICTORY!',
          style: TextStyle(
            fontFamily: 'MedievalSharp',
            color: Colors.amber,
            fontSize: 32,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Congratulations! You have acquired the legendary trophy and completed the game!',
              style: TextStyle(
                fontFamily: 'MedievalSharp',
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ImageButton(
              imagePath: 'assets/images/UI/Buttons/Button_Blue_3Slides.png',
              pressedImagePath:
                  'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png',
              text: 'Return to Main Menu',
              width: 200,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainMenu()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final playerData = ref.watch(playerDataProvider);
    final shopItems = ref.watch(shopItemsProvider);

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

          // Shop UI
          SafeArea(
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animation),
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Shop Header
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/UI/Ribbons/Ribbon_Blue_3Slides.png',
                            width: screenSize.width * 0.35,
                            height: screenSize.height *
                                0.08, // Add height constraint to keep it proportional
                            fit: BoxFit.contain,
                          ),
                          Text(
                            'SHOP',
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

                      // Player Gold Display
                      if (playerData != null)
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: screenSize.height *
                                  0.005), // Reduced from 0.01
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                screenSize.width * 0.02, // Reduced from 0.03
                            vertical:
                                screenSize.height * 0.004, // Reduced from 0.008
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius:
                                BorderRadius.circular(8), // Reduced from 10
                            border: Border.all(
                                color: Colors.amber,
                                width: 1.5), // Reduced border width from 2
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.monetization_on,
                                  color: Colors.amber,
                                  size: screenSize.width *
                                      0.03), // Reduced from 0.04
                              SizedBox(width: 4), // Reduced from 8
                              Text(
                                'Gold: ${playerData.gold}',
                                style: TextStyle(
                                  fontFamily: 'MedievalSharp',
                                  fontSize: screenSize.width *
                                      0.03, // Reduced from 0.035
                                  color: Colors.amber,
                                ),
                              ),
                            ],
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

                      // Shop Items Grid
                      Expanded(
                        child: shopItems.when(
                          data: (items) {
                            if (items.isEmpty) {
                              return Center(
                                child: Text(
                                  'No items available',
                                  style: TextStyle(
                                    fontFamily: 'MedievalSharp',
                                    fontSize: screenSize.width * 0.04,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              padding: EdgeInsets.all(screenSize.width * 0.02),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: screenSize.width > 800
                                    ? 4
                                    : (screenSize.width > 600 ? 3 : 2),
                                childAspectRatio: 0.85,
                                crossAxisSpacing: screenSize.width * 0.02,
                                mainAxisSpacing: screenSize.width * 0.02,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return _buildShopItem(
                                    context, item, playerData);
                              },
                            );
                          },
                          loading: () => Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                          ),
                          error: (error, stack) => Center(
                            child: Text(
                              'Error loading items: $error',
                              style: TextStyle(
                                fontFamily: 'MedievalSharp',
                                fontSize: screenSize.width * 0.03,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      // Back Button
                      Container(
                        margin: EdgeInsets.only(top: screenSize.height * 0.02),
                        child: ImageButton(
                          imagePath:
                              'assets/images/UI/Buttons/Button_Red_3Slides.png',
                          pressedImagePath:
                              'assets/images/UI/Buttons/Button_Red_3Slides_Pressed.png',
                          text: 'BACK',
                          width: screenSize.width * 0.2,
                          onPressed: () {
                            HapticFeedback.lightImpact();
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

          // Selected Item Detail Popup
          if (_selectedItem != null && playerData != null)
            _buildItemDetailPopup(context, _selectedItem!, playerData),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShopItem(
      BuildContext context, ShopItem item, PlayerData? playerData) {
    final screenSize = MediaQuery.of(context).size;
    bool canAfford = playerData != null && playerData.gold >= item.price;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedItem = item;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: item.isTrophy ? Colors.amber : Colors.blue.shade300,
            width: item.isTrophy ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isTrophy
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.blue.shade300.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Item Icon
            Container(
              width: screenSize.width * 0.06,
              height: screenSize.width * 0.06,
              decoration: BoxDecoration(
                color: item.isTrophy
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isTrophy
                    ? Icons.emoji_events
                    : item.affects == 'health'
                        ? Icons.favorite
                        : item.affects == 'damage'
                            ? Icons.flash_on
                            : Icons.directions_run,
                color: item.isTrophy
                    ? Colors.amber
                    : item.affects == 'health'
                        ? Colors.red
                        : item.affects == 'damage'
                            ? Colors.orange
                            : Colors.green,
                size: screenSize.width * 0.035,
              ),
            ),
            SizedBox(height: screenSize.height * 0.005),

            // Item Name
            Text(
              item.name,
              style: TextStyle(
                fontFamily: 'MedievalSharp',
                fontSize: screenSize.width * 0.022,
                fontWeight: FontWeight.bold,
                color: item.isTrophy ? Colors.amber : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.height * 0.003),

            // Item Effect
            Text(
              item.isTrophy
                  ? 'Legendary Trophy'
                  : '+${item.increaseAmount.toInt()} ${item.affects.capitalize()}',
              style: TextStyle(
                fontFamily: 'MedievalSharp',
                fontSize: screenSize.width * 0.018,
                color: item.affects == 'health'
                    ? Colors.red
                    : item.affects == 'damage'
                        ? Colors.orange
                        : item.affects == 'moveSpeed'
                            ? Colors.green
                            : Colors.amber,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.height * 0.008),

            // Item Price
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.015,
                vertical: screenSize.height * 0.003,
              ),
              decoration: BoxDecoration(
                color: canAfford
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: canAfford ? Colors.amber : Colors.red.shade300,
                    size: screenSize.width * 0.02,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '${item.price}',
                    style: TextStyle(
                      fontFamily: 'MedievalSharp',
                      fontSize: screenSize.width * 0.02,
                      color: canAfford ? Colors.amber : Colors.red.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetailPopup(
      BuildContext context, ShopItem item, PlayerData playerData) {
    final screenSize = MediaQuery.of(context).size;
    bool canAfford = playerData.gold >= item.price;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItem = null;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping on the card
            child: Container(
              width: screenSize.width * 0.65, // Reduced width
              padding:
                  EdgeInsets.all(screenSize.width * 0.02), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10), // Smaller radius
                border: Border.all(
                  color: item.isTrophy ? Colors.amber : Colors.blue.shade300,
                  width: item.isTrophy ? 2 : 1, // Thinner border
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.isTrophy
                        ? Colors.amber.withOpacity(0.3)
                        : Colors.blue.shade300.withOpacity(0.2),
                    spreadRadius: 1, // Reduced spread
                    blurRadius: 5, // Reduced blur
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with name and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontFamily: 'MedievalSharp',
                            fontSize: screenSize.width * 0.035, // Smaller font
                            fontWeight: FontWeight.bold,
                            color: item.isTrophy ? Colors.amber : Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Close Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedItem = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.01),

                  // Item information row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Icon
                      Container(
                        width: screenSize.width * 0.1, // Smaller icon
                        height: screenSize.width * 0.1,
                        decoration: BoxDecoration(
                          color: item.isTrophy
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.isTrophy
                              ? Icons.emoji_events
                              : item.affects == 'health'
                                  ? Icons.favorite
                                  : item.affects == 'damage'
                                      ? Icons.flash_on
                                      : Icons.directions_run,
                          color: item.isTrophy
                              ? Colors.amber
                              : item.affects == 'health'
                                  ? Colors.red
                                  : item.affects == 'damage'
                                      ? Colors.orange
                                      : Colors.green,
                          size: screenSize.width * 0.06,
                        ),
                      ),
                      SizedBox(width: 10),

                      // Description and effects column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Item Description
                            Container(
                              padding: EdgeInsets.all(screenSize.width * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.description,
                                style: TextStyle(
                                  fontFamily: 'MedievalSharp',
                                  fontSize:
                                      screenSize.width * 0.025, // Smaller font
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: 5),

                            // Item Effect
                            if (!item.isTrophy)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.affects == 'health'
                                          ? Icons.favorite
                                          : item.affects == 'damage'
                                              ? Icons.flash_on
                                              : Icons.directions_run,
                                      color: item.affects == 'health'
                                          ? Colors.red
                                          : item.affects == 'damage'
                                              ? Colors.orange
                                              : Colors.green,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '+${item.increaseAmount.toInt()} ${item.affects.capitalize()}',
                                      style: TextStyle(
                                        fontFamily: 'MedievalSharp',
                                        fontSize: screenSize.width * 0.025,
                                        color: item.affects == 'health'
                                            ? Colors.red
                                            : item.affects == 'damage'
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.01),

                  // Price and Purchase Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: canAfford
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: canAfford
                                  ? Colors.amber
                                  : Colors.red.shade300,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${item.price}',
                              style: TextStyle(
                                fontFamily: 'MedievalSharp',
                                fontSize: screenSize.width * 0.03,
                                color: canAfford
                                    ? Colors.amber
                                    : Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Buy Button
                      ImageButton(
                        imagePath: canAfford
                            ? 'assets/images/UI/Buttons/Button_Blue_3Slides.png'
                            : 'assets/images/UI/Buttons/Button_Red_3Slides.png',
                        pressedImagePath: canAfford
                            ? 'assets/images/UI/Buttons/Button_Blue_3Slides_Pressed.png'
                            : 'assets/images/UI/Buttons/Button_Red_3Slides_Pressed.png',
                        text: canAfford ? 'BUY' : 'NO',
                        width: screenSize.width * 0.15, // Smaller button
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          if (canAfford) {
                            _purchaseItem(item, playerData);
                            setState(() {
                              _selectedItem = null;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

// Provider to track whether the game has been completed (trophy purchased)
final gameCompletedProvider = StateProvider<bool>((ref) => false);
