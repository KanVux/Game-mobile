import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/collisions/custom_hitbox.dart';
import 'package:shieldbound/src/utils.dart';

enum PlayerState {
  idleLeft,
  idleRight,
  walkLeft,
  walkRight,
  attackRight,
  attackLeft,
  hurt,
  die,
}

enum PlayerFacing { left, right }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<Shieldbound>, KeyboardHandler, TapCallbacks {
  // ignore: use_super_parameters
  Player({position, this.character = "Soldier"}) : super(position: position);
  String character;

  // Định nghĩa các params cho sprite
  final vectorSize = Vector2.all(50);

  // Định nghĩa các thông số mặc định của nhân vật
  double moveSpeed = 100; // Tốc độ di chuyển mặc định
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

  // Trạng thái player
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

  // Các thông số phục vụ tính Collision
  List<CollisionBlock> collisionBlocks = [];
  // Tạo hitbox tùy chọn cho player một cách chính xác hơn
  CustomHitbox playerHitbox = CustomHitbox(
    offset: Vector2(20, 20),
    size: Vector2(10, 15),
  );
  // Timer cho animation attack
  late Timer attackTimer;
  @override
  FutureOr<void> onLoad() {
    // Những method và function được thêm vào đây sẽ được chạy khi game load
    debugMode = isDebugModeActived;
    _loadAllAnimation();

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

    // Thêm hitbox vào player
    add(RectangleHitbox(
      position: playerHitbox.offset,
      size: playerHitbox.size,
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Cập nhật game theo tick
    if (isAttackingAnimationPlaying) {
      attackTimer.update(dt);
    }
    _updatePlayerMovement(dt);
    _updatePlayerState();
    _checkCollisionAndResolve();
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

  void _loadAllAnimation() {
    // Load tất cả các Animation
    idleLeftAnimation =
        _spriteAnimation('Idle_Left', 6); // Animation đứng chờ trái
    idleRightAnimation =
        _spriteAnimation('Idle_Right', 6); // Animation đứng chờ phải
    walkLeftAnimation =
        _spriteAnimation('Walk_Left', 8); // Animation đi qua trái
    walkRightAnimation =
        _spriteAnimation('Walk_Right', 8); // Animation đi qua phải
    attackRightAnimation =
        _spriteAnimation('Attack01_Right', 6, stepTime: 0.05);
    attackLeftAnimation = _spriteAnimation('Attack01_Left', 6, stepTime: 0.05);

    // Gán các Animation cho các state của player
    animations = {
      PlayerState.idleLeft: idleLeftAnimation,
      PlayerState.idleRight: idleRightAnimation,
      PlayerState.walkLeft: walkLeftAnimation,
      PlayerState.walkRight: walkRightAnimation,
      PlayerState.attackRight: attackRightAnimation,
      PlayerState.attackLeft: attackLeftAnimation,
    };

    // Đặt state/animation mặc định
    current = PlayerState.idleRight;
  }

  void resetToIdleState() {
    playerState = lastFacingDirection == PlayerFacing.left
        ? PlayerState.idleLeft
        : PlayerState.idleRight;
    current = playerState;
  }

  SpriteAnimation _spriteAnimation(String state, int amount,
      {double stepTime = 0.1}) {
    // Load các ảnh của nhân vật $character đang ở trạng thái $state từ Cache
    var spriteImages = game.images
        .fromCache('Characters/$character/$character/$character-$state.png');
    // Lấy data từ Spritesheets theo kiểu sequenced với:
    /*   amount: số lượng sprite trong một sheet(theo kiểu sequence),
         stepTime: thời gian để chạy animation giữa các sprite trong sequence,
         textureSize: là độ lớn của sprite */
    var animationData = SpriteAnimationData.sequenced(
        amount: amount, stepTime: stepTime, textureSize: vectorSize);

    return SpriteAnimation.fromFrameData(
      spriteImages,
      animationData,
    );
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
    if (isAttackingAnimationPlaying) return;
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

  void _checkCollisionAndResolve() {
    for (final block in collisionBlocks) {
      final collision = checkCollisionWithBlock(this, block);

      if (collision.isCollided) {
        // Resolve collision based on the side
        switch (collision.collisionSide) {
          case "top":
            position.y = block.y - playerHitbox.size.y - playerHitbox.offset.y;
            velocity.y = 0; // Stop downward movement
            break;
          case "bottom":
            position.y = block.y + block.height - playerHitbox.offset.y;
            velocity.y = 0; // Stop upward movement
            break;
          case "left":
            position.x = block.x - playerHitbox.size.x - playerHitbox.offset.x;
            velocity.x = 0; // Stop leftward movement
            break;
          case "right":
            position.x = block.x + block.width - playerHitbox.offset.x;
            velocity.x = 0; // Stop rightward movement
            break;
        }
      }
    }
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
