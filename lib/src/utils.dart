import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/player.dart';

bool isCollided(Player player, CollisionBlock block) {
  final hitbox = player.playerHitbox;

  final playerX = player.position.x + hitbox.offset.x;
  final playerY = player.position.y + hitbox.offset.y;
  final playerWidth = hitbox.size.x;
  final playerHeight = hitbox.size.y;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // Trả về true nếu player nằm TRONG hay ĐANG VA CHẠM một khối
  return (playerY + playerHeight > blockY &&
      playerY < blockY + blockHeight &&
      playerX + playerWidth > blockX &&
      playerX < blockX + blockWidth);
}
