import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/components.dart';
import 'package:shieldbound/src/models/enemy.dart';
import 'package:shieldbound/src/models/enermies_classes/boss.dart';


final gameCompletedProvider = StateProvider<bool>((ref) => false);

class EnemySpawnController extends StateNotifier<List<Enemy>> {
  EnemySpawnController() : super([]);

  // Số enemy tối đa được spawn
  final int maxEnemies = 3;
  bool bossSpawned = false;

  /// Spawns multiple enemy at spawnPoint. Nếu chưa đạt maxEnemies, spawn enemy theo factory,
  /// còn nếu đạt ngưỡng và boss chưa spawn thì spawn boss.
  void trySpawnEnemy(
      Enemy Function(Vector2 position) enemyFactory, Vector2 spawnPoint) {
    if (state.length < maxEnemies) {
      // Với mỗi spawn point, ví dụ spawn 3 enemy có offset nhỏ.
      for (int i = 0; i < 3 && state.length < maxEnemies; i++) {
        final pos = spawnPoint + Vector2(10.0 * i, 0);
        final enemy = enemyFactory(pos);
        state = [...state, enemy];
      }
    } else if (!bossSpawned) {
      bossSpawned = true;
      final boss = EliteOrc(position: spawnPoint);
      state = [...state, boss];
    }
  }

  void removeEnemy(Enemy enemy) {
    state = state.where((e) => e != enemy).toList();

  }
}

final enemySpawnProvider =
    StateNotifierProvider<EnemySpawnController, List<Enemy>>((ref) {
  return EnemySpawnController();
});
