import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/utils/damageable.dart';
import 'package:shieldbound/src/models/enemy.dart';
import 'package:shieldbound/src/services/audio_service.dart';

class EnemyMeleeAttack extends PositionComponent
    with CollisionCallbacks, HasGameRef<Shieldbound> {
  final double damage;
  final double radius;

  EnemyMeleeAttack(
      {required this.damage, this.radius = 13.0, required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(radius * 2),
        );
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    // Play enemy attack sound
    AudioService()
        .playSoundEffect('enemy_attack', 'audio/sound_effects/atk_sound.wav');

    add(
      CircleHitbox()..radius = radius,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) return;
    debugPrint("EnemyMeleeAttack va chạm với: ${other.runtimeType}");
    if (other is Damageable) {
      (other as Damageable).takeDamage(damage);

      // Play hit sound
      AudioService().playSoundEffect('enemy_hit', 'audio/sound_effects/atk_sound_hitted.wav');

      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
