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
      left: 0,
      top: 0,
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
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vàng: ${gold.toString()}',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.amber,
                fontFamily: 'MedievalSharp',
              ),
            ),
            Text(
              'Máu: ${health.toString()}',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.red,
                fontFamily: 'MedievalSharp',
              ),
            ),
            Text(
              'Damage: ${damage.toString()}',
              style: const TextStyle(
                fontSize: 15,
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
