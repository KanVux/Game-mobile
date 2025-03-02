import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
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
    // Thêm CircleHitbox với bán kính đã định nghĩa.
    add(
      CircleHitbox()..radius = radius,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) return;
    if (other is Interactable) return;
    // Kiểm tra xem đối tượng va chạm có implement Damageable không
    debugPrint("SwordSlashAttack va chạm với: ${other.runtimeType}");
    if (other is Damageable) {
      (other as Damageable).takeDamage(damage);
      // Nếu muốn chỉ tác động một lần, có thể xóa hitbox sau va chạm
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
