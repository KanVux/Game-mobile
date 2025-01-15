import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/src/game_map.dart';
import 'package:shieldbound/src/player.dart';

class Shieldbound extends FlameGame with HasKeyboardHandlerComponents {
  late final CameraComponent cam;
  final double windowWidth = 640;
  final double windowHeight = 360;

  Player player = Player(character: 'Soldier');
  late JoystickComponent joystick;
  bool isJoystickActive = true;

  @override
  FutureOr<void> onLoad() async {
    // Load toàn bộ ảnh trong assets vào Cache
    // TODO: Kiểm tra ở đây nếu bị giảm hiệu xuất
    // (nếu có dấu hiệu bị giảm performance thì chuyển lại chỉ load các image cần thiết)
    await images.loadAllImages();

    // Tạo một map
    final gameMap = GameMap(
      mapName: 'map_01',
      player: player,
    );
    // Tạo góc camera với:
    // world: gameMap
    // width: chiều rộng cửa sổ game
    // height: chiều cao cửa sổ game
    cam = CameraComponent.withFixedResolution(
      world: gameMap,
      width: windowWidth,
      height: windowHeight,
    );

    // Ghim camera vào phía trên bên trái vị trí (0, 0) (Tính góc trên bên trái là gốc tọa độ)
    cam.viewfinder.anchor = Anchor.topLeft;
    // Độ ưu tiên của cam
    cam.priority = 0;

    addAll([cam, gameMap]);
    if (isJoystickActive) {
      addJoystick();
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isJoystickActive) {
      updateJoystick();
    }
    super.update(dt);
  }

  // Thêm joystick cho người chơi trên thiết bị di động
  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('Hub/joystick_knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('Hub/joystick_background.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
      knobRadius: 30,
    );
    cam.viewport.add(joystick);
  }

  void updateJoystick() {
    // TODO: Sửa lại joystick control cho mobile
    switch (joystick.direction) {
      case JoystickDirection.up:
        player.moveDirection.y = -1;
        break;
      case JoystickDirection.down:
        player.moveDirection.y = 1;
        break;
      case JoystickDirection.left:
        player.moveDirection.x = -1;
        break;
      case JoystickDirection.right:
        player.moveDirection.x = 1;
        break;
      case JoystickDirection.upLeft:
        player.moveDirection.y = -1;
        player.moveDirection.x = -1;
        break;
      case JoystickDirection.upRight:
        player.moveDirection.y = -1;
        player.moveDirection.x = 1;
        break;
      case JoystickDirection.downLeft:
        player.moveDirection.y = 1;
        player.moveDirection.x = -1;
        break;
      case JoystickDirection.downRight:
        player.moveDirection.y = 1;
        player.moveDirection.x = 1;
        break;
      default:
        player.moveDirection.x = 0;
        player.moveDirection.y = 0;
        break;
    }
  }
}
