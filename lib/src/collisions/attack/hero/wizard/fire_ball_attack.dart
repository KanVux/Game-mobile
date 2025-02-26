import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/models/player.dart';
import 'package:shieldbound/src/utils/damageable.dart';

class FireballAttack extends SpriteAnimationComponent
    with HasGameRef<Shieldbound>, CollisionCallbacks {
  final double speed = 140; // Tốc độ bay của fireball
  final double damage;
  final Vector2 direction;
  final double radius = 10; // Bán kính hitbox
  CircleHitbox? hitbox;

  FireballAttack({
    required this.damage,
    required Vector2 position,
    required this.direction,
  }) : super(
          position: position, // Giữ nguyên vị trí khi spawn
          size: Vector2.all(50), // Kích thước fireball khớp với textureSize
          anchor: Anchor.center, // Đặt tâm fireball là điểm gốc
        ) {
    scale.x = direction.x < 0 ? -1 : 1;
  }

  @override
  Future<void> onLoad() async {
    debugMode = isDebugModeActived;

    // Load animation từ file ảnh
    animation = await gameRef.loadSpriteAnimation(
      'Characters/Wizard/effect/Fireball.png',
      SpriteAnimationData.sequenced(
        amount: 7, // Số frame trong animation
        stepTime: 0.2, // Thời gian chuyển frame
        textureSize: Vector2.all(50), // Kích thước sprite animation
      ),
    );

    // Thêm hitbox ban đầu
    hitbox = CircleHitbox(
      radius: radius,
      anchor: Anchor.center,
      position: Vector2(30, 27),
    );
    add(hitbox!);

    // Sau amount * steptime (khoảng frame thứ 6), mở rộng hitbox thành vụ nổ
    Future.delayed(Duration(milliseconds: 1200), () {
      if (!isRemoved) {
        hitbox?.radius = radius * 1.4; // Tăng kích thước hitbox
      }
    });

    // Xóa sau khi animation kết thúc amount * steptime
    Future.delayed(Duration(milliseconds: 1400), () {
      removeFromParent();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (position.x <= gameRef.windowWidth && position.x >= 0) {
      position += direction * speed * dt; // Di chuyển fireball theo hướng
    } else {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) return; // Không va chạm với người chơi
    if (other is Damageable) {
      (other as Damageable).takeDamage(damage);
      removeFromParent(); // Xóa fireball khi va chạm
    }
    super.onCollision(intersectionPoints, other);
  }
}
