import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/utils/damageable.dart';
import 'package:shieldbound/src/models/enemy.dart';

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
    print("EnemyMeleeAttack va chạm với: ${other.runtimeType}");
    if (other is Damageable) {
      (other as Damageable).takeDamage(damage);
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
