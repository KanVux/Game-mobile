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

    return super.onLoad();
  }
}
