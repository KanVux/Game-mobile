import 'dart:async';
import 'package:flame/components.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/src/collisions/attack/hero/wizard/fire_ball_attack.dart';
import 'package:shieldbound/src/models/player.dart';

class Wizard extends Player {
  Wizard({Vector2? position})
      : super(
          health: 100,
          maxHealth: 100,
          moveSpeed: 80,
          damage: 30,
          position: position ?? Vector2.zero(),
          character: 'Wizard',
        );

  @override
  FutureOr<void> onLoad() {
    debugMode = isDebugModeActivated;
    return super.onLoad();
  }

  @override
  void attack() {
    if (isAttackingAnimationPlaying) return;

    isAttackingAnimationPlaying = true;
    // Play casting sound effect
    playerState = lastFacingDirection == PlayerFacing.left
        ? PlayerState.attackLeft
        : PlayerState.attackRight;
    current = playerState;

    // Sử dụng absolutePosition thay vì position
    Vector2 fireballPosition = absolutePosition + Vector2(20, 10);

    // Xác định hướng bay
    Vector2 direction = lastFacingDirection == PlayerFacing.right
        ? Vector2(1, 0)
        : Vector2(-1, 0);

    // Tạo fireball với vị trí global chính xác
    FireballAttack fireball = FireballAttack(
      damage: damage,
      position: fireballPosition,
      direction: direction,
    );

    // Thêm fireball vào cùng parent của wizard (map)
    parent?.add(fireball);

    // Kết thúc animation attack sau 500ms
    Future.delayed(Duration(milliseconds: 500), () {
      isAttacking = false;
    });
  }
}
