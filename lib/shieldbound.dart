import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/src/models/hero_classes/soilder.dart';
import 'package:shieldbound/src/ui/mobile/attack.dart';
import 'package:shieldbound/src/game_map.dart';
import 'package:shieldbound/src/models/player.dart';

class Shieldbound extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final CameraComponent cam;
  final double windowWidth = 640;
  final double windowHeight = 360;

  Player player = Soldier();
  late JoystickComponent joystick;
  bool isJoystickActive = false;

  @override
  FutureOr<void> onLoad() async {
    // Load toàn bộ ảnh trong assets vào Cache
    // TODO: Kiểm tra ở đây nếu bị giảm hiệu xuất
    // (nếu có dấu hiệu bị giảm performance thì chuyển lại chỉ load các image cần thiết)
    await images.loadAllImages();

    // Tạo một map
    final gameMap = GameMap(
      mapName: 'Home',
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

    cam.viewfinder.anchor = Anchor.center;
    cam.follow(player);
    // Độ ưu tiên của cam
    cam.priority = 0;
    await addAll([cam, gameMap]);

    if (isJoystickActive) {
      addJoystick();
      cam.viewport.add(Attack());
    }
    cam.viewport.add(FpsTextComponent());

    Rectangle worldBound = Rectangle.fromLTRB(
        windowWidth / 2,
        windowHeight / 2,
        gameMap.mapWidth - windowWidth / 2,
        gameMap.mapHeight - windowHeight / 2);
    cam.setBounds(worldBound as Shape?);
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
    final direction = joystick.relativeDelta;
    if (direction != Vector2.zero()) {
      player.moveDirection = direction.normalized();
    } else {
      player.moveDirection = Vector2.zero();
    }
  }
}
