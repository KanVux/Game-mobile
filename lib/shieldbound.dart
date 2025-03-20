import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/src/models/hero_classes/soilder.dart';
import 'package:shieldbound/src/providers/provider.dart';
import 'package:shieldbound/src/services/audio_service.dart';
import 'package:shieldbound/src/ui/mobile/attack.dart';
import 'package:shieldbound/src/ui/mobile/pause_button.dart';
import 'package:shieldbound/src/game_map.dart';
import 'package:shieldbound/src/models/player.dart';

class Shieldbound extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks,
        RiverpodGameMixin {
  late final CameraComponent cam;
  final double windowWidth = 640;
  final double windowHeight = 360;
  Player player = Soldier();
  // Player player = Wizard();

  late JoystickComponent joystick;
  bool isJoystickActive = true;

  // Pause state
  bool isPaused = false;
  Function? onGamePaused; // Callback when game is paused

  bool playSounds = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Khởi tạo player trước
      player = Soldier();

      // Cập nhật provider với player instance
      ref.read(playerProvider.notifier).state = player;

      // Cập nhật health provider với giá trị máu ban đầu
      ref.read(playerHealthProvider.notifier).state = player.health.toInt();

      // Load images first
      await images.loadAllImages();

      // Sử dụng ref từ RiverpodGameMixin
      final audioService = ref.read(audioServiceProvider);
      await audioService.initialize();
      await audioService.playBackgroundMusic('musics/2.mp3');
      debugPrint('Error initializing audio service');

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
      cam.priority = -1;
      await addAll([cam, gameMap]);

      if (isJoystickActive) {
        addJoystick();
        cam.viewport.add(Attack()..priority = 200);
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
    } catch (e) {
      debugPrint('Error in onLoad: $e');
    }
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
      if (player.moveDirection.x < 0) {
        player.lastFacingDirection = PlayerFacing.left;
      } else {
        player.lastFacingDirection = PlayerFacing.right;
      }
    } else {
      player.moveDirection = Vector2.zero();
    }
  }

  // Toggle game pause state
  void togglePause() {
    isPaused = !isPaused;

    if (isPaused) {
      AudioService().stopBackgroundMusic();
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
}
