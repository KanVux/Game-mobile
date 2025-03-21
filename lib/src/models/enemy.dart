import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/collisions/custom_hitbox.dart';
import 'package:shieldbound/src/collisions/utils.dart';
import 'package:shieldbound/src/services/audio_service.dart';
import 'package:shieldbound/src/utils/damageable.dart';

import '../providers/provider.dart';
import '../services/pocketbase_service.dart';

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
  final double detectionRange = 140; // Phạm vi phát hiện player
  final double attackRange = 20; // Phạm vi tấn công
  bool isAttacking = false;
  late Timer attackCooldown;
  final double attackCooldownDuration = 3.0; //3 giây giữa các đòn tấn công
  // Add an avoidance margin for the larger hitbox
  final double avoidanceMargin = 30.0;

  @override
  FutureOr<void> onLoad() async {
    debugMode = isDebugModeActivated;
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
      // If enemy dies, award gold to the player
      _awardGoldToPlayer();

      // If enemy is dead, change to death state based on current direction
      if (current == EnemyState.idleLeft ||
          current == EnemyState.walkLeft ||
          current == EnemyState.attackLeft) {
        current = EnemyState.deathLeft;
      } else {
        current = EnemyState.deathRight;
      }
      // Force non-null animation
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
      // If enemy is still alive, play hurt animation
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
            // After hurt animation completes, return to idle state
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

// Add this private method to award gold to the player
  void _awardGoldToPlayer() {
    try {
      // Award different gold amounts based on enemy type
      int goldAmount = 10; // Base gold amount

      // Award more gold for boss enemies
      if (enemyName == 'EliteOrc') {
        goldAmount = 50;
      } else if (enemyName == 'Orc') {
        goldAmount = 20;
      }

      // Get the player data from the provider
      final playerData = game.ref.read(playerDataProvider);
      if (playerData != null) {
        // Add gold to player
        playerData.gold += goldAmount;

        // Update the gold provider
        game.ref.read(playerGoldProvider.notifier).state = playerData.gold;

        // Save to PocketBase in the background
        Future(() async {
          final pocketbaseService = game.ref.read(pocketbaseServiceProvider);
          await pocketbaseService.updatePlayer(playerData);
        });

        debugPrint("Awarded $goldAmount gold to player");
      }
    } catch (e) {
      debugPrint("Error awarding gold: $e");
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

    if (distance <= detectionRange && !game.player.isDead) {
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
    _onCollision();
  }

  /// Hàm này tính lực đẩy các enemy khi quá gần nhau
  void _chasePlayer(Vector2 playerPosition, double dt) {
    // Hướng đến player
    final chaseDirection = (playerPosition - position).normalized();

    // Tạo vector ngẫu nhiên để tránh đi cùng đường
    final randomOffset = Vector2.random() - Vector2.all(0.5);
    randomOffset.scale(0.3); // Điều chỉnh độ lệch ngẫu nhiên

    // Kết hợp cả 3 hướng di chuyển
    final combinedDirection =
        (chaseDirection * 0.6 + randomOffset).normalized();

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
      // Lấy vector hướng từ enemy bị va chạm đến enemy hiện tại
      Vector2 pushDirection = (position - other.position).normalized();

      // Đẩy enemy ra xa nhau, giữ khoảng cách tối thiểu
      double minimumDistance =
          vectorSize.x; // Khoảng cách tối thiểu giữa hai enemy
      double currentDistance = position.distanceTo(other.position);

      if (currentDistance < minimumDistance) {
        // Đẩy ra xa một khoảng cách nhỏ để tránh chồng lên nhau
        double pushAmount = (minimumDistance - currentDistance) / 100;
        position += pushDirection * pushAmount;
        other.position -= pushDirection * pushAmount;
      }
    }
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
