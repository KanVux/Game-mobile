import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/custom_hitbox.dart';
import 'package:shieldbound/src/collisions/attack/enemy/enemy_melee_attack.dart';
import 'package:shieldbound/src/utils/damageable.dart';

enum EnemyState {
  idleLeft,
  idleRight,
  walkLeft,
  walkRight,
  attackRight,
  attackLeft,
  hurtLeft,
  hurtRight,
  deathRight,
  deathLeft,
}

enum EnemyFacing {
  left,
  right,
}

class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with HasGameRef<Shieldbound>, CollisionCallbacks
    implements Damageable {
  // ignore: use_super_parameters
  Enemy({
    required this.health,
    required this.damage,
    required this.moveSpeed,
    super.position,
    required this.enemyName,
  }) : super();

  String enemyName;
  double health;
  double damage;
  double moveSpeed;
  Vector2 vectorSize = Vector2.all(50);
  EnemyFacing lastFacingDirection = EnemyFacing.right;
  // Ví dụ về vận tốc, hướng di chuyển (có thể bổ sung logic di chuyển sau)
  double speed = 100;
  Vector2 velocity = Vector2.zero();

  // Hitbox của enemy
  CustomHitbox enemyHitbox = CustomHitbox(
    offset: Vector2(20, 20),
    size: Vector2(10, 15),
  );

  @override
  FutureOr<void> onLoad() async {
    debugMode = isDebugModeActived;
    // Load các animation dựa trên enemyName (điều chỉnh theo asset của bạn)
    animations = await _loadAnimations(enemyName);
    // Thiết lập trạng thái mặc định (ví dụ: idleRight)
    current = EnemyState.idleRight;
    add(RectangleHitbox(
      position: enemyHitbox.offset,
      size: enemyHitbox.size,
    ));
    return super.onLoad();
  }

  Future<Map<EnemyState, SpriteAnimation>> _loadAnimations(
      String character) async {
    Map<EnemyState, SpriteAnimation> animations = {};

    const animationTypes = {
      EnemyState.walkLeft: 'Walk',
      EnemyState.walkRight: 'Walk',
      EnemyState.idleLeft: 'Idle',
      EnemyState.idleRight: 'Idle',
      EnemyState.attackLeft: 'Attack01',
      EnemyState.attackRight: 'Attack01',
      EnemyState.hurtLeft: 'Hurt',
      EnemyState.hurtRight: 'Hurt',
      EnemyState.deathLeft: 'Death',
      EnemyState.deathRight: 'Death',
    };

    for (var entry in animationTypes.entries) {
      var state = entry.key;
      var action = entry.value;

      String direction = (state.toString().contains('Left')) ? 'Left' : 'Right';
      String animationPath =
          'Characters/$character/$character/$character-$action'
          '_$direction.png';
      var image = await gameRef.images.load(animationPath);
      int frameCount = image.width ~/ 50;
      animations[state] = SpriteAnimation.fromFrameData(
        gameRef.images.fromCache(animationPath),
        SpriteAnimationData.sequenced(
          amount: frameCount,
          stepTime: 0.1,
          textureSize: Vector2.all(50),
        ),
      );
    }
    return animations;
  }

  @override
  void takeDamage(double damageTaken) {
    print("$enemyName nhận sát thương: $damageTaken");
    health -= damageTaken;

    if (health <= 0) {
      // Nếu enemy chết, chuyển sang trạng thái death dựa trên hướng hiện tại
      if (current == EnemyState.idleLeft ||
          current == EnemyState.walkLeft ||
          current == EnemyState.attackLeft) {
        current = EnemyState.deathLeft;
      } else {
        current = EnemyState.deathRight;
      }
      // Ép kiểu animations không null
      final deathAnim = animations![current];
      if (deathAnim != null) {
        Future.delayed(
          Duration(
            milliseconds: (deathAnim.totalDuration() * 1000).toInt(),
          ),
          () {
            removeFromParent();
          },
        );
      } else {
        removeFromParent();
      }
    } else {
      // Nếu enemy còn sống, chuyển sang trạng thái hurt và play animation hurt
      EnemyState hurtState;
      if (current == EnemyState.idleLeft ||
          current == EnemyState.walkLeft ||
          current == EnemyState.attackLeft) {
        hurtState = EnemyState.hurtLeft;
      } else {
        hurtState = EnemyState.hurtRight;
      }
      current = hurtState;
      final hurtAnim = animations![hurtState];
      if (hurtAnim != null) {
        Future.delayed(
          Duration(
            milliseconds: (hurtAnim.totalDuration() * 1000).toInt(),
          ),
          () {
            // Sau khi animation hurt hoàn thành, chuyển lại về trạng thái idle tương ứng
            if (hurtState == EnemyState.hurtLeft) {
              current = EnemyState.idleLeft;
            } else {
              current = EnemyState.idleRight;
            }
          },
        );
      }
    }
  }

  void spawnMeleeAttack() {
    // Tính toán vị trí của đòn chém dựa theo hướng của nhân vật
    Vector2 attackPosition;
    if (lastFacingDirection == EnemyFacing.right) {
      // Ví dụ: đặt hitbox ở bên phải của nhân vật
      attackPosition = Vector2(
          enemyHitbox.offset.x,
          enemyHitbox.offset.y -
              enemyHitbox.size.y / 2); // điều chỉnh theo yêu cầu
    } else {
      // Nếu hướng trái, đặt hitbox bên trái
      attackPosition = Vector2(enemyHitbox.offset.x - (enemyHitbox.size.x + 6),
          enemyHitbox.offset.y - enemyHitbox.size.y / 2);
    }
    // Lấy sát thương cho đòn chém từ thuộc tính damage của nhân vật (hoặc có thể là thuộc tính riêng của vũ khí)
    double meleeDamage = damage; // có thể điều chỉnh sau này dễ dàng

    // Tạo instance của SwordSlashAttack
    EnemyMeleeAttack meleeSlash = EnemyMeleeAttack(
      damage: meleeDamage,
      position: attackPosition,
    );

    // Thêm SwordSlashAttack vào cây component của Player hoặc gameRef tùy theo cách tổ chức của bạn
    add(meleeSlash);

    // Nếu muốn, tự động xóa hitbox sau một khoảng thời gian ngắn (ví dụ: 200ms) nếu không có va chạm xảy ra
    Future.delayed(Duration(milliseconds: 200), () {
      meleeSlash.removeFromParent();
    });
  }
}

/// Extension giúp tính tổng thời gian của một animation
extension SpriteAnimationExtension on SpriteAnimation {
  double totalDuration() {
    double duration = 0;
    for (final frame in frames) {
      duration += frame.stepTime;
    }
    return duration;
  }
}
