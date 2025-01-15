import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:shieldbound/shieldbound.dart';

enum PlayerState { idleLeft, idleRight, walkLeft, walkRight }

enum PlayerAction { attack, hurt, die }

enum PlayerFacing { left, right }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<Shieldbound>, KeyboardHandler {
  // ignore: use_super_parameters
  Player({position, this.character = "Soldier"}) : super(position: position);
  String character;

  // Định nghĩa các params cho sprite
  final playerHitboxSize = Vector2.all(22);
  final vectorSize = Vector2.all(32);
  final double stepTime = 0.1;

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

  // Định nghĩa các SpriteAnimation
  late final SpriteAnimation idleLeftAnimation;
  late final SpriteAnimation idleRightAnimation;
  late final SpriteAnimation walkLeftAnimation;
  late final SpriteAnimation walkRightAnimation;

  @override
  FutureOr<void> onLoad() {
    // Những method và function được thêm vào đây sẽ được chạy khi game load
    _loadAllAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Cập nhật game theo tick
    _updatePlayerMovement(dt);
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
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    // Nếu di chuyển qua phải bằng nút D hoặc nút →
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

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
      playerFacing = PlayerFacing.left;
    } else if (isRightKeyPressed) {
      playerFacing = PlayerFacing.right;
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

    // Gán các Animation cho các state của player
    animations = {
      PlayerState.idleLeft: idleLeftAnimation,
      PlayerState.idleRight: idleRightAnimation,
      PlayerState.walkLeft: walkLeftAnimation,
      PlayerState.walkRight: walkRightAnimation,
    };

    // Đặt state/animation mặc định
    current = PlayerState.idleRight;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
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
    // Vận tốc = hướng di chuyển * tốc độ di chuyển
    velocity.x = moveDirection.x * moveSpeed;
    velocity.y = moveDirection.y * moveSpeed;
    // Vị trí sau khi di chuyển = Vận tốc * delta time
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
  }
}
