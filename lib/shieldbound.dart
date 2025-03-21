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

import 'src/models/hero_classes/wizard.dart';
import 'src/models/player_data.dart';
import 'src/services/pocketbase_service.dart';

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
      // Load player data from PocketBase if available
      final pocketbaseService = ref.read(pocketbaseServiceProvider);
      final playerId = ref.read(currentPlayerIdProvider);

      PlayerData? playerData;

      if (playerId != null) {
        // Try to load existing player
        playerData = await pocketbaseService.getPlayer(playerId);
      }

      if (playerData == null) {
        // Create a new player if not found
        // Lưu ý: Chúng ta không tự tạo người chơi mới ở đây nữa
        // vì điều này được xử lý bởi màn hình chọn nhân vật

        // Chuyển hướng về màn hình chọn nhân vật sẽ được xử lý ở UI
        // Do đó chỉ log thông báo
        print(
            'No player data found, user should select or create player first');
      } else {
        // Update player based on stored data
        if (playerData.character == 'Wizard') {
          player = Wizard();
        } else {
          player = Soldier();
        }

        // Apply stored stats
        player.health = playerData.maxHealth;
        player.maxHealth = playerData.maxHealth;
        player.damage = playerData.damage;
        player.moveSpeed = playerData.moveSpeed;

        playerData.health = playerData.maxHealth;

        // Update providers
        ref.read(playerDataProvider.notifier).state = playerData;
        ref.read(playerGoldProvider.notifier).state = playerData.gold;
        ref.read(playerHealthProvider.notifier).state = player.health.toInt();
      }

      // Update providers with player instance
      ref.read(playerProvider.notifier).state = player;
      ref.read(playerHealthProvider.notifier).state = player.health.toInt();

      // Load images first
      await images.loadAllImages();

      // Use ref from RiverpodGameMixin
      final audioService = ref.read(audioServiceProvider);
      await audioService.initialize();
      await audioService.playBackgroundMusic('musics/2.mp3');

      // Create a map
      final gameMap = GameMap(
        mapName: 'Home',
        player: player,
      );

      // Create camera component with:
      // world: gameMap
      // width: window width
      // height: window height
      cam = CameraComponent.withFixedResolution(
        world: gameMap,
        width: windowWidth,
        height: windowHeight,
      );

      cam.viewfinder.anchor = Anchor.center;
      cam.follow(player);
      // Camera priority
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
      pauseEngine();
      AudioService().stopBackgroundMusic();
      if (onGamePaused != null) {
        onGamePaused!();
      }
      player.moveDirection = Vector2.zero();
    } else {
      resumeEngine();
      if (playSounds) {
        ref.read(audioServiceProvider).playBackgroundMusic('musics/2.mp3');
      }
    }
  }

  // Resume the game
  void resumeGame() {
    if (isPaused) {
      isPaused = false;
      resumeEngine();
      if (playSounds) {
        ref.read(audioServiceProvider).playBackgroundMusic('musics/2.mp3');
      }
    }
  }
}
