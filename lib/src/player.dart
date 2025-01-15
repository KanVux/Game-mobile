import 'dart:async';

import 'package:flame/components.dart';
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
  double moveSpeed = 100; // Tốc độ di chuyển
  Vector2 moveDirection = Vector2
      .zero(); // Hướng di chuyển (Giải thích: (a,b) = a cho hướng trái phải và b cho lên xuống)
  Vector2 velocity = Vector2
      .zero(); // Vận tốc ban đầu khi không di chuyển = (0, 0) (Giải thích: do không di chuyển qua lại hoặc trái phải);
  PlayerState playerState = PlayerState
      .idleRight; // Cho state mặc định của nhân vật là "đứng chờ quay mặt phải"
  PlayerFacing playerFacing =
      PlayerFacing.right; // Cho hướng quay mặt mặc định là phải

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
        .fromCache('Character/$character/$character/$character-$state.png');
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
}
