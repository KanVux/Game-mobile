import 'package:flame/components.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/src/collisions/attack/hero/soldier/sword_slash_attack.dart';
import 'package:shieldbound/src/models/player.dart';

class Soldier extends Player {
  Soldier({Vector2? position})
      : super(
          health: 150,
          maxHealth: 150,
          damage: 20,
          moveSpeed: 100,
          position: position ?? Vector2.zero(),
          character: 'Soldier',
        );

  @override
  Future<void> onLoad() async {
    debugMode = isDebugModeActivated;
    if (debugMode) damage = 100;
    await super.onLoad();
    // Có thể thêm logic đặc biệt cho Soldier ở đây
  }

  @override
  void attack() {
    if (isAttackingAnimationPlaying) return;

    isAttacking = true;
    isAttackingAnimationPlaying = true;

    // Thay đổi hướng tấn công dựa theo hướng di chuyển của nhân vật
    playerState = lastFacingDirection == PlayerFacing.left
        ? PlayerState.attackLeft
        : PlayerState.attackRight;
    current = playerState;

    Future.delayed(Duration(milliseconds: 300), () {
      spawnSwordSlashAttack();
    });

    attackTimer.start();
  }

  void spawnSwordSlashAttack() {
    Vector2 attackPosition;
    if (lastFacingDirection == PlayerFacing.right) {
      attackPosition = Vector2(
        playerHitbox.offset.x,
        playerHitbox.offset.y - playerHitbox.size.y / 2,
      );
    } else {
      attackPosition = Vector2(
        playerHitbox.offset.x - (playerHitbox.size.x + 6),
        playerHitbox.offset.y - playerHitbox.size.y / 2,
      );
    }

    double slashDamage = damage;

    SwordSlashAttack swordSlash = SwordSlashAttack(
      damage: slashDamage,
      position: attackPosition,
    );
    add(swordSlash);

    Future.delayed(Duration(milliseconds: 200), () {
      if (swordSlash.isMounted) {
        swordSlash.removeFromParent();
      }
    });
  }
}
