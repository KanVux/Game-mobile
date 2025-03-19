import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/models/interactable.dart';
import 'package:shieldbound/src/utils/damageable.dart';
import 'package:shieldbound/src/models/player.dart';

class SwordSlashAttack extends PositionComponent
    with CollisionCallbacks, HasGameRef<Shieldbound> {
  final double damage;
  final double radius;

  /// [position]: vị trí spawn của đòn tấn công .
  /// [radius]: bán kính của hitbox hình tròn, mặc định là 13.
  SwordSlashAttack({
    required this.damage,
    required Vector2 position,
    this.radius = 13.0,
  }) : super(
          position: position,
          size: Vector2.all(radius * 2),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (game.playSounds) {
      FlameAudio.play(
        'sound_effects/sword_slash_attack.mp3',
        volume: game.volume,
      );
    }
    // Thêm CircleHitbox với bán kính đã định nghĩa.
    add(
      CircleHitbox()..radius = radius,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) return;
    if (other is Interactable) return;

    debugPrint("SwordSlashAttack va chạm với: ${other.runtimeType}");
    if (other is Damageable) {
      (other as Damageable).takeDamage(damage);

      // Play hit sound when successfully hitting something

      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
