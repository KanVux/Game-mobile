import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/providers/provider.dart';

// final playerHealthProvider = StateProvider<int>((ref) => 150);
final playerMaxHealthProvider = StateProvider<int>((ref) => 100);
final playerDamageProvider = StateProvider<int>((ref) => 20);
final playerGoldProvider = StateProvider<int>((ref) => 0);

class HudOverlay extends ConsumerWidget {
  const HudOverlay({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy trạng thái từ provider
    final health = ref.watch(playerHealthProvider);
    final gold =  ref.watch(playerGoldProvider);
    final damage = ref.watch(playerDamageProvider);
    
    return Positioned(
      left: 28,
      top: 50,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/Hub/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vàng: ${gold.toString()}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.amber,
                fontFamily: 'MedievalSharp',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Máu: ${health.toString()}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.red,
                fontFamily: 'MedievalSharp',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Damage: ${damage.toString()}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'MedievalSharp',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
