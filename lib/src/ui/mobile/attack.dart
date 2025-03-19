import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/custom_hitbox.dart';
import 'package:shieldbound/src/models/player.dart';

class Attack extends SpriteComponent
    with HasGameRef<Shieldbound>, TapCallbacks {
  Attack();
  final margin = 32;
  final buttonSize = 100;

  late final Sprite attackButton;
  late final Sprite attackButtonActive;

  late Timer attackTimer;
  bool isAttackAnimationPlaying = false;

  CustomHitbox weaponHitbox = CustomHitbox(
    offset: Vector2(27, 25),
    size: Vector2(15, 15),
  );

  @override
  FutureOr<void> onLoad() async {
    // Load sprites
    attackButton = _loadButtonSprite(action: 'attack_button');
    attackButtonActive =
        _loadButtonSprite(action: 'attack_button', state: 'active');
    sprite = attackButton;

    // Set position relative to viewport
    position = Vector2(
        game.windowWidth - margin - buttonSize,
        game.windowHeight - margin - buttonSize,
        );

    // Initialize timer with fixed duration first
    attackTimer = Timer(
      0.4, // Default duration
      onTick: () {
        isAttackAnimationPlaying = false;
        game.player.isAttackingAnimationPlaying = false;
        game.player.resetToIdleState();
        sprite = attackButton;
      },
    );

    size = Vector2.all(buttonSize.toDouble());

    return super.onLoad();
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (!game.player.isAttackingAnimationPlaying) {
      attackTimer.start();
      // HapticFeedback.mediumImpact();
      game.player.attack();
      sprite = attackButtonActive;
    }
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (game.player.isAttackingAnimationPlaying) {
      game.player.isAttacking = false;
    }
    sprite = attackButton;
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    if (game.player.isAttackingAnimationPlaying) {
      game.player.isAttacking = false;
    }
    return true;
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    if (game.player.isAttackingAnimationPlaying) {
      game.player.isAttacking = false;
    }
    sprite = attackButton;
  }

  @override
  void update(double dt) {
    if (isAttackAnimationPlaying) {
      attackTimer.update(dt);
    }
    super.update(dt);
  }

  Sprite _loadButtonSprite({String? action, String? state}) {
    return (state == null)
        ? Sprite(game.images.fromCache('Hub/$action.png'))
        : Sprite(game.images.fromCache('Hub/${action}_$state.png'));
  }
}
