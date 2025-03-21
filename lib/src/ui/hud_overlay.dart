import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/providers/provider.dart';
final playerDamageProvider = StateProvider<int>((ref) => 20);
class HudOverlay extends ConsumerWidget {
  const HudOverlay({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy trạng thái từ provider
    final health = ref.watch(playerHealthProvider);
    final gold = ref.watch(playerGoldProvider);
    final damage = ref.watch(playerDamageProvider);

    // Debug print to verify values
    debugPrint("HUD rebuild with gold=$gold, health=$health, damage=$damage");

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
