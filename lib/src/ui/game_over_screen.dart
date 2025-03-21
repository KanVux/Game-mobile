import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/ui/game_wrapper.dart';

// Riverpod provider to store gold earned
final goldProvider =StateProvider<int>((ref) => 0);

class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    // Read the current gold earned
    //final int goldEarned = ref.watch(goldProvider);
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          width: size.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: 40,
                  color: Colors.redAccent,
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
                'Vàng thu được: ${ref.watch(goldProvider)}',
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: 24,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  // Navigate back to Home (the map lobby)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameWrapper(),
                    ),
                  );
                },
                child: Text(
                  'QUAY VỀ HOME',
                  style: TextStyle(
                    fontFamily: 'MedievalSharp',
                    fontSize: 20,
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