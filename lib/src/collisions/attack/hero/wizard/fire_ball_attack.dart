import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/models/player.dart';
import 'package:shieldbound/src/utils/damageable.dart';
import 'package:shieldbound/src/services/audio_service.dart';

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

    // Play fireball launch sound
    AudioService().playSoundEffect('fireball_launch', 'audio/sound_effects/fire_atk_sound_launch.wav');

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
        hitbox?.radius = radius * 1.4;
        AudioService().playSoundEffect(
            'fireball_explode', 'audio/sound_effects/fire_atk_sound.wav'); // ADD FIRE BALL SFX LATER
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
    if (other is Player) return;
    if (other is Damageable) {
      (other as Damageable).takeDamage(damage);

      // Play hit sound
      AudioService()
          .playSoundEffect('fireball_hit', 'audio/sound_effects/fire_atk_sound_hitted.wav');

      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
