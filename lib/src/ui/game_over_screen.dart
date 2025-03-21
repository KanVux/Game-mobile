import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/providers/enemy_provider.dart';
import 'package:shieldbound/src/providers/provider.dart';
import 'package:shieldbound/src/services/pocketbase_service.dart';
import 'package:shieldbound/src/ui/game_wrapper.dart';
import 'package:shieldbound/src/ui/menu/main_menu.dart';

// Riverpod provider to store gold earned

class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final playerData = ref.watch(playerDataProvider);
    final goldEarned = ref.watch(playerGoldProvider);
    final isGameCompleted = ref.watch(gameCompletedProvider);

    // Save player data
    Future(() async {
      if (playerData != null) {
        final pocketbaseService = ref.read(pocketbaseServiceProvider);
        await pocketbaseService.updatePlayer(playerData);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          width: size.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isGameCompleted ? Colors.green : Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isGameCompleted ? 'CHIẾN THẮNG!' : 'GAME OVER',
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: 40,
                  color:
                      isGameCompleted ? Colors.greenAccent : Colors.redAccent,
                  shadows: const [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Vàng thu được: $goldEarned',
                style: const TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: 24,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (isGameCompleted) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    ref.read(gameCompletedProvider.notifier).state = false;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainMenu(),
                      ),
                    );
                  },
                  child: const Text(
                    'TRỞ VỀ MÀN HÌNH CHÍNH',
                    style: TextStyle(
                      fontFamily: 'MedievalSharp',
                      fontSize: 20,
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameWrapper(),
                      ),
                    );
                  },
                  child: const Text(
                    'THỬ LẠI',
                    style: TextStyle(
                      fontFamily: 'MedievalSharp',
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
