import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/collisions/custom_hitbox.dart';
import 'package:shieldbound/src/models/interactable.dart';
import 'package:shieldbound/src/providers/enemy_provider.dart';
import 'package:shieldbound/src/providers/provider.dart';
import 'package:shieldbound/src/services/audio_service.dart';
import 'package:shieldbound/src/utils/damageable.dart';
import 'package:shieldbound/src/collisions/utils.dart';

import '../services/pocketbase_service.dart';

enum PlayerState {
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

enum PlayerFacing { left, right }

abstract class Player extends SpriteAnimationGroupComponent
    with
        HasGameRef<Shieldbound>,
        KeyboardHandler,
        TapCallbacks,
        CollisionCallbacks,
        RiverpodComponentMixin
    implements Damageable {
  Player({
    required this.health,
    required this.maxHealth,
    required this.damage,
    required this.moveSpeed,
    required Vector2 position,
    required this.character,
  }) : super() {
    this.position = position;
  }
  // Định nghĩa các thông số mặc định của nhân vật
  final String character;
  double moveSpeed;
  double health;
  double maxHealth;
  double damage;

  // XỬ LÝ DI CHUYỂN VÀ TRẠNG THÁI
  Vector2 moveDirection = Vector2
      .zero(); // Hướng di chuyển (Giải thích: (a,b) = a cho hướng trái phải và b cho lên xuống)
  Vector2 velocity = Vector2
      .zero(); // Vận tốc ban đầu khi không di chuyển = (0, 0) (Giải thích: do không di chuyển qua lại hoặc lên xuống);
  PlayerState playerState = PlayerState
      .idleRight; // Cho state mặc định của nhân vật là "đứng chờ quay mặt phải"
  PlayerFacing playerFacing =
      PlayerFacing.right; // Cho hướng quay mặt mặc định là "phải"
  PlayerFacing lastFacingDirection =
      PlayerFacing.right; // Hướng quay ở lần quay cuối (Mặc định là "phải")

  Vector2 previousPosition = Vector2.zero();

  // Flag trạng thái
  bool isDead = false;
  bool isHurt = false;
  bool isAttacking = false;
  bool isAttackingAnimationPlaying = false;

  // Định nghĩa các SpriteAnimation
  late final SpriteAnimation idleLeftAnimation;
  late final SpriteAnimation idleRightAnimation;
  late final SpriteAnimation walkLeftAnimation;
  late final SpriteAnimation walkRightAnimation;
  late final SpriteAnimation attackRightAnimation;
  late final SpriteAnimation attackLeftAnimation;
  late final SpriteAnimation hurtLeftAnimation;
  late final SpriteAnimation hurtRightAnimation;
  late final SpriteAnimation deathLeftAnimation;
  late final SpriteAnimation deathRightAnimation;

  // Danh sách các block có thể va chạm
  List<CollisionBlock> collisionBlocks = [];

  // Hitbox đúng của nhân vật
  CustomHitbox playerHitbox = CustomHitbox(
    offset: Vector2(18, 20),
    size: Vector2(9, 10),
  );

  // Timer cho animation attack
  late Timer attackTimer;

  // Thêm biến để track thời gian animation hurt
  late Timer hurtTimer;

  @override
  FutureOr<void> onLoad() async {
    // Những method và function được thêm vào đây sẽ được chạy khi game load
    debugMode = isDebugModeActivated;
    // Load Animation
    await _loadAllAnimation();
    // Bắt đầu timer cho attack
    attackTimer = Timer(
      attackRightAnimation.totalDuration(),
      onTick: () {
        isAttacking = false;
        isAttackingAnimationPlaying = false;
        resetToIdleState();
      },
      repeat: false,
    );
    // Scale kích thước nhân vật
    scale = Vector2.all(1.5);
    // Thêm hitbox vào player
    add(RectangleHitbox(
      position: playerHitbox.offset,
      size: playerHitbox.size * scale.x,
    ));

    // Khởi tạo hurt timer
    hurtTimer = Timer(0.4, onTick: () {
      isHurt = false;
      if (!isDead) {
        resetToIdleState();
      }
    });

    // Thêm listener để cập nhật provider khi health thay đổi

    return super.onLoad();
  }

  @override
  void update(double dt) {
    final isGameCompleted = ref.watch(gameCompletedProvider);
    previousPosition = position.clone();
    if (isGameCompleted) {
      removeFromParent();
      gameRef.overlays.add('GameOverScreen');
    }
    if (isHurt) {
      hurtTimer.update(dt);
    } else if (!isDead) {
      if (isAttackingAnimationPlaying) {
        attackTimer.update(dt);
      }
      _updatePlayerMovement(dt);
      _updatePlayerState();
    }

    _onCollision();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Bắt sự kiện ấn phím
    // Mặc định
    moveDirection = Vector2.zero();
    // Nếu di chuyển lên bằng nút W hoặc nút ↑
    final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    // Nếu di chuyển xuống bằng nút S hoặc nút ↓
    final isDownKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);
    // Nếu di chuyển qua trái bằng nút A hoặc nút ←
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    // Nếu di chuyển qua phải bằng nút D hoặc nút →
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    // Player tấn công
    // Player attacks
    if (!isAttackingAnimationPlaying &&
        keysPressed.contains(LogicalKeyboardKey.space)) {
      attack();
      isAttacking = true;
      isAttackingAnimationPlaying = true;

      // Set attack state based on the last facing direction
      playerState = lastFacingDirection == PlayerFacing.left
          ? PlayerState.attackLeft
          : PlayerState.attackRight;

      current = playerState;

      // Start the attack animation timer
      attackTimer.start();
    }
    // Xác định hướng di chuyển
    moveDirection.y += isUpKeyPressed ? -1 : 0;
    moveDirection.y += isDownKeyPressed ? 1 : 0;
    moveDirection.x += isLeftKeyPressed ? -1 : 0;
    moveDirection.x += isRightKeyPressed ? 1 : 0;

    // Khi player di chuyển theo đường chéo
    // Tính tổng độ dài vector
    final magnitude = sqrt(pow(moveDirection.x, 2) + pow(moveDirection.y, 2));
    if (magnitude > 0) {
      // Chuẩn hóa vector
      moveDirection.x /= magnitude;
      moveDirection.y /= magnitude;
    }

    // Kiểm tra hướng quay của player
    if (isLeftKeyPressed) {
      lastFacingDirection = PlayerFacing.left;
    } else if (isRightKeyPressed) {
      lastFacingDirection = PlayerFacing.right;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  Future<void> _loadAllAnimation() async {
    var loadedAnimations = await _loadAnimations(character);

    // Gán animation đã load vào các biến tương ứng
    idleLeftAnimation = loadedAnimations[PlayerState.idleLeft]!;
    idleRightAnimation = loadedAnimations[PlayerState.idleRight]!;
    walkLeftAnimation = loadedAnimations[PlayerState.walkLeft]!;
    walkRightAnimation = loadedAnimations[PlayerState.walkRight]!;
    attackRightAnimation = loadedAnimations[PlayerState.attackRight]!;
    attackLeftAnimation = loadedAnimations[PlayerState.attackLeft]!;
    hurtRightAnimation = loadedAnimations[PlayerState.hurtRight]!;
    hurtLeftAnimation = loadedAnimations[PlayerState.hurtLeft]!;
    deathRightAnimation = loadedAnimations[PlayerState.deathRight]!;
    deathLeftAnimation = loadedAnimations[PlayerState.deathLeft]!;
    // Gán lại vào danh sách animations của player
    animations = {
      PlayerState.idleLeft: idleLeftAnimation,
      PlayerState.idleRight: idleRightAnimation,
      PlayerState.walkLeft: walkLeftAnimation,
      PlayerState.walkRight: walkRightAnimation,
      PlayerState.attackRight: attackRightAnimation,
      PlayerState.attackLeft: attackLeftAnimation,
      PlayerState.hurtLeft: hurtLeftAnimation,
      PlayerState.hurtRight: hurtRightAnimation,
      PlayerState.deathLeft: deathLeftAnimation,
      PlayerState.deathRight: deathRightAnimation,
    };

    // Đặt state mặc định
    current = PlayerState.idleRight;
  }

  Future<Map<PlayerState, SpriteAnimation>> _loadAnimations(
      String character) async {
    Map<PlayerState, SpriteAnimation> animations = {};

    const animationTypes = {
      PlayerState.walkLeft: 'Walk',
      PlayerState.walkRight: 'Walk',
      PlayerState.idleLeft: 'Idle',
      PlayerState.idleRight: 'Idle',
      PlayerState.attackLeft: 'Attack01',
      PlayerState.attackRight: 'Attack01',
      PlayerState.hurtLeft: 'Hurt',
      PlayerState.hurtRight: 'Hurt',
      PlayerState.deathLeft: 'Death',
      PlayerState.deathRight: 'Death',
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

  void resetToIdleState() {
    // Reset trạng thái nhân vật về idle
    playerState = lastFacingDirection == PlayerFacing.left
        ? PlayerState.idleLeft
        : PlayerState.idleRight;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (isAttackingAnimationPlaying) {
      // Prevent movement when attacking
      velocity = Vector2.zero();
      return;
    }
    // Vận tốc = hướng di chuyển * tốc độ di chuyển
    velocity.x = moveDirection.x * moveSpeed;
    velocity.y = moveDirection.y * moveSpeed;
    // Vị trí sau khi di chuyển = Vận tốc * delta time
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
  }

  void _updatePlayerState() {
    // Skip state updates if hurt or attacking
    if (isAttackingAnimationPlaying || isHurt) return;
    if (velocity.x < 0 ||
        (velocity.x < 0 && velocity.y != 0) ||
        (lastFacingDirection == PlayerFacing.left && velocity.y != 0)) {
      playerState = PlayerState.walkLeft;
    } else if (velocity.x > 0 ||
        (velocity.x > 0 && velocity.y != 0) ||
        (lastFacingDirection == PlayerFacing.right && velocity.y != 0)) {
      playerState = PlayerState.walkRight;
    } else if (isAttacking) {
      playerState = lastFacingDirection == PlayerFacing.left
          ? PlayerState.attackLeft
          : PlayerState.attackRight;
    } else {
      playerState = lastFacingDirection == PlayerFacing.left
          ? PlayerState.idleLeft
          : PlayerState.idleRight;
    }

    current = playerState;
  }

  void _onCollision() {
    for (final block in collisionBlocks) {
      final collision = checkCollisionWithBlock(this, block);

      if (collision.isCollided) {
        // Resolve collision based on the side
        switch (collision.collisionSide) {
          case "top":
            position.y = block.y -
                (playerHitbox.size.y * scale.y) -
                (playerHitbox.offset.y * scale.y);
            velocity.y = 0; // Stop downward movement
            break;
          case "bottom":
            position.y =
                block.y + block.height - (playerHitbox.offset.y * scale.y);
            velocity.y = 0; // Stop upward movement
            break;
          case "left":
            position.x = block.x -
                (playerHitbox.size.x * scale.x) -
                (playerHitbox.offset.x * scale.x);
            velocity.x = 0; // Stop leftward movement
            break;
          case "right":
            position.x =
                block.x + block.width - (playerHitbox.offset.x * scale.x);
            velocity.x = 0; // Stop rightward movement
            break;
        }
      }
    }
  }

  @override
  void takeDamage(double damageTaken) {
    if (health <= 0 || isHurt) return;

    debugPrint("$character nhận sát thương: $damageTaken");

    if (game.playSounds) {
      FlameAudio.play('sound_effects/enemy_hit_sound.wav',
          volume: AudioService().volume);
    }

    health -= damageTaken;
    if (health < 0) health = 0;

    // Update player health provider
    game.ref.read(playerHealthProvider.notifier).state = health.toInt();

    // Update PocketBase if we have player data
    final playerData = game.ref.read(playerDataProvider);
    if (playerData != null) {
      playerData.health = health;

      // Use a Future to update PocketBase without blocking the game
      Future(() async {
        final pocketbaseService = game.ref.read(pocketbaseServiceProvider);
        await pocketbaseService.updatePlayer(playerData);
      });
    }

    isHurt = true;

    // Cancel any ongoing attack
    isAttacking = false;
    isAttackingAnimationPlaying = false;

    // Force hurt animation
    playerState = lastFacingDirection == PlayerFacing.left
        ? PlayerState.hurtLeft
        : PlayerState.hurtRight;
    current = playerState;

    // Stop movement
    velocity = Vector2.zero();
    moveDirection = Vector2.zero();

    if (health <= 0) {
      isDead = true;
      playerState = lastFacingDirection == PlayerFacing.left
          ? PlayerState.deathLeft
          : PlayerState.deathRight;
      current = playerState;

      final deathAnim = animations![current]!;
      Future.delayed(
        Duration(milliseconds: (deathAnim.totalDuration() * 1000).toInt()),
        () {
          removeFromParent();
          gameRef.overlays.add('GameOverScreen');
        },
      );
    } else {
      hurtTimer.start();
    }
  }

  void heal(int amount) {
    health += amount;
    if (health > maxHealth) health = maxHealth;
    game.ref.read(playerHealthProvider.notifier).state = health.toInt();
  }

  // Overide ở lớp con
  void attack() {}

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Interactable) {
      position = previousPosition.clone() + velocity * -0.001;
    }
    super.onCollision(intersectionPoints, other);
  }
}

extension SpriteAnimationExtension on SpriteAnimation {
  double totalDuration() {
    double duration = 0;
    for (final frame in frames) {
      duration += frame.stepTime;
    }
    return duration;
  }
}
