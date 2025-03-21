import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/src/models/interactable.dart';
import 'package:shieldbound/src/models/player.dart';

class HealingHouseComponent extends SpriteComponent with CollisionCallbacks implements Interactable {
  HealingHouseComponent({required Vector2 position})
      : super(
          position: position,
        );

  @override
  FutureOr<void> onLoad() async {
    debugMode = isDebugModeActivated;
    sprite = await Sprite.load(
        'Factions/Goblins/Buildings/Wood_House/Goblin_House.png');
    size = Vector2(100, 150);
    anchor = Anchor.center;
    add(RectangleHitbox(
      position: Vector2(18, size.y / 2),
      size: Vector2(65, 55),
    )
      ..debugMode = isDebugModeActivated
      ..debugColor = Colors.yellow);
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      // Xử lý logic hồi máu cho nhân vật
      (other).heal(50);
    }
  }
}
