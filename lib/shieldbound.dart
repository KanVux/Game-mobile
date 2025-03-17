import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/src/models/hero_classes/soilder.dart';
import 'package:shieldbound/src/ui/mobile/attack.dart';
import 'package:shieldbound/src/ui/mobile/pause_button.dart';
import 'package:shieldbound/src/game_map.dart';
import 'package:shieldbound/src/models/player.dart';
import 'package:shieldbound/src/services/audio_service.dart';

class Shieldbound extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  
  late final CameraComponent cam;
  final double windowWidth = 640;
  final double windowHeight = 360;
  final AudioService audioService = AudioService();

  Player player = Soldier();
  late JoystickComponent joystick;
  bool isJoystickActive = true;

  // Pause state
  bool isPaused = false;
  Function? onGamePaused; // Callback when game is paused

  @override
  FutureOr<void> onLoad() async {
    // Load toàn bộ ảnh trong assets vào Cache
    // TODO: Kiểm tra ở đây nếu bị giảm hiệu xuất
    // (nếu có dấu hiệu bị giảm performance thì chuyển lại chỉ load các image cần thiết)
    await images.loadAllImages();
    await audioService.initialize();

    // Play background music
    audioService.playBackgroundMusic('audio/musics/2.mp3');

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

    // Add pause button
    cam.viewport.add(PauseButton());

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
    if (isPaused) return; // Skip updates when paused

    if (isJoystickActive) {
      updateJoystick();
    }
    super.update(dt);
  }

  // Thêm joystick cho người chơi trên thiết bị di động
  void addJoystick() {
    joystick = JoystickComponent(
      priority: 200,
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

  // Toggle game pause state
  void togglePause() {
    isPaused = !isPaused;

    if (isPaused) {
      // Pause the game and trigger the callback
      if (onGamePaused != null) {
        onGamePaused!();
      }
      // Stop player movement
      player.moveDirection = Vector2.zero();
    }

    // You might add sound effects here
  }

  // Resume the game
  void resumeGame() {
    isPaused = false;
  }
  @override
  void onRemove() {
    audioService.stopBackgroundMusic();
    super.onRemove();
  }
}
