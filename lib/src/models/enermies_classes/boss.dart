import 'package:flame/components.dart';
import 'package:shieldbound/src/collisions/attack/enemy/enemy_melee_attack.dart';
import 'package:shieldbound/src/models/enemy.dart';
import 'package:shieldbound/src/providers/enemy_provider.dart';

class EliteOrc extends Enemy {
  EliteOrc({Vector2? position}) // Cho phép position là null
      : super(
          health: 300,
          damage: 30,
          moveSpeed: 80,
          position: position ??
              Vector2.zero(), // Mặc định là (0,0) nếu không truyền vào
          enemyName: 'EliteOrc',
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Có thể thêm logic đặc biệt cho Orc ở đây
  }

  void spawnMeleeAttack() {
    // Tính toán vị trí của đòn chém dựa theo hướng của nhân vật
    Vector2 attackPosition;
    if (lastFacingDirection == EnemyFacing.right) {
      // Ví dụ: đặt hitbox ở bên phải của nhân vật
      attackPosition = Vector2(
          enemyHitbox.offset.x,
          enemyHitbox.offset.y -
              enemyHitbox.size.y / 2); // điều chỉnh theo yêu cầu
    } else {
      // Nếu hướng trái, đặt hitbox bên trái
      attackPosition = Vector2(enemyHitbox.offset.x - (enemyHitbox.size.x + 6),
          enemyHitbox.offset.y - enemyHitbox.size.y / 2);
    }
    // Lấy sát thương cho đòn chém từ thuộc tính damage của nhân vật (hoặc có thể là thuộc tính riêng của vũ khí)
    double meleeDamage = damage; // có thể điều chỉnh sau này dễ dàng

    // Tạo instance của SwordSlashAttack
    EnemyMeleeAttack meleeSlash = EnemyMeleeAttack(
      damage: meleeDamage,
      position: attackPosition,
    );

    // Thêm SwordSlashAttack vào cây component của Player hoặc gameRef tùy theo cách tổ chức
    add(meleeSlash);

    // Nếu muốn, tự động xóa hitbox sau một khoảng thời gian ngắn (ví dụ: 200ms) nếu không có va chạm xảy ra
    Future.delayed(Duration(milliseconds: 200), () {
      meleeSlash.removeFromParent();
    });
  }

  @override
  void attack() {
    isAttacking = true;
    attackCooldown.start();

    // Set attack animation
    current = lastFacingDirection == EnemyFacing.left
        ? EnemyState.attackLeft
        : EnemyState.attackRight;

    // Spawn attack hitbox after a small delay to match animation
    Future.delayed(Duration(milliseconds: 200), () {
      spawnMeleeAttack();
    });

    // Reset to idle after attack animation
    Future.delayed(
      Duration(
          milliseconds: (animations![current]!.totalDuration() * 1000).toInt()),
      () {
        if (!isAttacking) return;
        current = lastFacingDirection == EnemyFacing.left
            ? EnemyState.idleLeft
            : EnemyState.idleRight;
      },
    );
  }

  @override
  void onRemove() {
    game.ref.read(gameCompletedProvider.notifier).state = true;
    super.onRemove();
  }
}
