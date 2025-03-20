import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/models/player.dart';
import 'package:shieldbound/src/utils/damageable.dart';
import 'package:shieldbound/src/models/enemy.dart';
// import 'package:shieldbound/src/services/audio_service.dart';

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
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) return; // Ignore collision with self

    debugPrint("EnemyMeleeAttack va chạm với: ${other.runtimeType}");
    if (other is Player) {
      // Check specifically for Player instead of Damageable
      other.takeDamage(damage);
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
