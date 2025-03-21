import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/components.dart';
import 'package:shieldbound/src/models/enemy.dart';
import 'package:shieldbound/src/models/enermies_classes/boss.dart';

final gameCompletedProvider = StateProvider<bool>((ref) => false);

class EnemySpawnController extends StateNotifier<List<Enemy>> {
  EnemySpawnController(this.ref) : super([]);
  final Ref ref;

  final int maxEnemies = 30;
  bool bossSpawned = false;

  void trySpawnEnemy(
      Enemy Function(Vector2 position) enemyFactory, Vector2 spawnPoint) {
    if (state.length < maxEnemies) {
      final newState = [...state];
      for (int i = 0; i < 3 && newState.length < maxEnemies; i++) {
        final pos = spawnPoint + Vector2(10.0 * i, 0);
        final enemy = enemyFactory(pos);
        newState.add(enemy);
        debugPrint('Enemy spawned: ${enemy.runtimeType} at position ${pos}');
      }
      state = newState;
    } else if (!bossSpawned) {
      bossSpawned = true;
      final boss = EliteOrc(position: spawnPoint);
      state = [...state, boss];
      debugPrint('Boss spawned at position ${spawnPoint}');
    }
    _logState();
  }

  void removeEnemy(Enemy enemy) {
    state = state.where((e) => e != enemy).toList();
  }

  void _logState() {
    debugPrint('Current state (${state.length} enemies):');
    for (var enemy in state) {
      debugPrint('- ${enemy.runtimeType} at ${enemy.position}');
    }
  }
}

// Update provider to pass ref to controller
final enemySpawnProvider =
    StateNotifierProvider<EnemySpawnController, List<Enemy>>((ref) {
  return EnemySpawnController(ref);
});
