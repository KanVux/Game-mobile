import 'dart:math';

import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/models/player.dart';

class CollisionInfo {
  final bool isCollided;
  final String collisionSide; // "top", "bottom", "left", "right"

  CollisionInfo(this.isCollided, this.collisionSide);
}

CollisionInfo checkCollisionWithBlock(Player player, CollisionBlock block) {
  final hitbox = player.playerHitbox;

  // Player hitbox coordinates
  final playerX = player.position.x + hitbox.offset.x;
  final playerY = player.position.y + hitbox.offset.y;
  final playerWidth = hitbox.size.x;
  final playerHeight = hitbox.size.y;

  // Block coordinates
  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // Check for overlap
  bool isCollided = playerX < blockX + blockWidth &&
      playerX + playerWidth > blockX &&
      playerY < blockY + blockHeight &&
      playerY + playerHeight > blockY;

  if (!isCollided) {
    return CollisionInfo(false, "");
  }

  // Calculate overlap for each side
  final double overlapTop = playerY + playerHeight - blockY;
  final double overlapBottom = blockY + blockHeight - playerY;
  final double overlapLeft = playerX + playerWidth - blockX;
  final double overlapRight = blockX + blockWidth - playerX;

  // Determine the smallest overlap and corresponding side
  double minOverlap =
      min(min(overlapTop, overlapBottom), min(overlapLeft, overlapRight));
  String collisionSide = "";

  if (minOverlap == overlapTop) {
    collisionSide = "top";
  } else if (minOverlap == overlapBottom) {
    collisionSide = "bottom";
  } else if (minOverlap == overlapLeft) {
    collisionSide = "left";
  } else if (minOverlap == overlapRight) {
    collisionSide = "right";
  }

  return CollisionInfo(true, collisionSide);
}
