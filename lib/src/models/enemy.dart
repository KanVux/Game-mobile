import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/collisions/custom_hitbox.dart';
import 'package:shieldbound/src/collisions/utils.dart';
import 'package:shieldbound/src/services/audio_service.dart';
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
  Vector2 previousPosition = Vector2.zero();
  // Hitbox của enemy
  CustomHitbox enemyHitbox = CustomHitbox(
    offset: Vector2(20, 20),
    size: Vector2(10, 15),
  );
  List<CollisionBlock> collisionBlocks = [];
  // Thêm các thuộc tính cho AI
  final double detectionRange = 200; // Phạm vi phát hiện player
  final double attackRange = 30; // Phạm vi tấn công
  bool isAttacking = false;
  late Timer attackCooldown;
  final double attackCooldownDuration = 2.0; // 2 giây giữa các đòn tấn công
  // Add an avoidance margin for the larger hitbox
  final double avoidanceMargin = 30.0;

  /// The enemy’s normal hitbox rectangle.
  Rect get hitboxRect => Rect.fromLTWH(
        position.x + enemyHitbox.offset.x * scale.x,
        position.y + enemyHitbox.offset.y * scale.y,
        enemyHitbox.size.x * scale.x,
        enemyHitbox.size.y * scale.y,
      );

  /// The larger avoidance rectangle around the enemy.
  Rect get avoidanceRect => Rect.fromLTWH(
        hitboxRect.left - avoidanceMargin,
        hitboxRect.top - avoidanceMargin,
        hitboxRect.width + avoidanceMargin * 2,
        hitboxRect.height + avoidanceMargin * 2,
      );

  /// Helper getter to obtain the center of the enemy's hitbox.
  Vector2 get hitboxCenter => Vector2(
        hitboxRect.center.dx,
        hitboxRect.center.dy,
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
      size: enemyHitbox.size * scale.x,
    ));
    scale = Vector2.all(1.5);

    await super.onLoad();

    // Khởi tạo timer cho cooldown tấn công
    attackCooldown = Timer(
      attackCooldownDuration,
      onTick: () {
        isAttacking = false;
      },
    );
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
    debugPrint("$enemyName nhận sát thương: $damageTaken");

    if (game.playSounds) {
      FlameAudio.play('sound_effects/enemy_hit_sound.wav',
          volume: AudioService().volume);
    }
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

  @override
  void update(double dt) {
    super.update(dt);
    previousPosition = position.clone();

    if (health <= 0) return; // Skip AI if dead

    attackCooldown.update(dt);

    // Tính khoảng cách đến player
    final playerPosition = game.player.position;
    final distance = position.distanceTo(playerPosition);

    if (distance <= detectionRange) {
      if (distance <= attackRange) {
        if (!isAttacking && attackCooldown.finished) {
          attack();
        }
      } else {
        _chasePlayer(playerPosition, dt);
      }
    } else {
      _idle();
    }

    // Áp dụng lực tránh va chạm giữa các enemy
    _avoidOverlap(dt);
    _onCollision();
  }

  /// Hàm này tính lực đẩy các enemy khi quá gần nhau
  void _chasePlayer(Vector2 playerPosition, double dt) {
    // Hướng đến player
    final chaseDirection = (playerPosition - position).normalized();

    // Tạo vector ngẫu nhiên để tránh đi cùng đường
    final randomOffset = Vector2.random() - Vector2.all(0.5);
    randomOffset.scale(0.3); // Điều chỉnh độ lệch ngẫu nhiên

    // Lực tách để tránh enemy chồng lên nhau
    final separationForce = _calculateSeparationForce();
    const double separationWeight = 4.0; // Tăng trọng số separation để mạnh hơn

    // Kết hợp cả 3 hướng di chuyển
    final combinedDirection = (chaseDirection * 0.6 +
            separationForce * separationWeight +
            randomOffset)
        .normalized();

    // Cập nhật vận tốc và vị trí
    velocity = combinedDirection * moveSpeed;
    position += velocity * dt;

    // Cập nhật hướng nhìn và animation dựa trên hướng di chuyển
    if (velocity.x < 0) {
      lastFacingDirection = EnemyFacing.left;
      current = EnemyState.walkLeft;
    } else {
      lastFacingDirection = EnemyFacing.right;
      current = EnemyState.walkRight;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      position = previousPosition;
    }
  }

  void _avoidOverlap(double dt) {
    Vector2 repulsion = Vector2.zero();
    int count = 0;

    for (final other in gameRef.children.whereType<Enemy>()) {
      if (other == this) continue;
      // Check if the other enemy is within our avoidance zone.
      if (avoidanceRect.overlaps(other.hitboxRect)) {
        final otherCenter = other.hitboxCenter;
        final difference = hitboxCenter - otherCenter;
        final distance = difference.length;
        if (distance == 0) continue;
        final pushVector = difference / distance;
        repulsion += pushVector;
        count++;
      }
    }

    if (count > 0) {
      repulsion.scale(1 / count.toDouble());
      // Adjust position based on the repulsion force.
      position += repulsion * dt * 100;
    }
  }

  /// Tính lực separation: trả về vector tách các enemy ra khỏi nhau dựa trên khoảng cách
  Vector2 _calculateSeparationForce() {
    Vector2 force = Vector2.zero();
    int count = 0;
    // Duyệt qua tất cả enemy khác trong game
    for (final other in gameRef.children.whereType<Enemy>()) {
      if (other == this) continue;
      final d = position.distanceTo(other.position);
      const double desiredSeparation =
          100; // khoảng cách mong muốn giữa các enemy
      if (d < desiredSeparation && d > 0) {
        // Lực đẩy càng lớn khi khoảng cách càng nhỏ
        final diff = (position - other.position).normalized() / d;
        force += diff;
        count++;
      }
    }
    if (count > 0) {
      force.scale(1 / count);
    }
    return force;
  }

  void attack() {}

  void _idle() {
    velocity = Vector2.zero();
    current = lastFacingDirection == EnemyFacing.left
        ? EnemyState.idleLeft
        : EnemyState.idleRight;
  }

  /// Phương thức di chuyển ngẫu nhiên: chọn hướng ngẫu nhiên và duy trì một khoảng thời gian

  void _onCollision() {
    for (final block in collisionBlocks) {
      final collision = checkEnemyCollisionWithBlock(this, block);

      if (collision.isCollided) {
        // Resolve collision based on the side
        switch (collision.collisionSide) {
          case "top":
            position.y = block.y -
                (enemyHitbox.size.y * scale.y) -
                (enemyHitbox.offset.y * scale.y);
            velocity.y = 0; // Stop downward movement
            break;
          case "bottom":
            position.y =
                block.y + block.height - (enemyHitbox.offset.y * scale.y);
            velocity.y = 0; // Stop upward movement
            break;
          case "left":
            position.x = block.x -
                (enemyHitbox.size.x * scale.x) -
                (enemyHitbox.offset.x * scale.x);
            velocity.x = 0; // Stop leftward movement
            break;
          case "right":
            position.x =
                block.x + block.width - (enemyHitbox.offset.x * scale.x);
            velocity.x = 0; // Stop rightward movement
            break;
        }
      }
    }
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
