import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/src/models/interactable.dart';

class HouseComponent extends SpriteComponent implements Interactable {
  HouseComponent({required Vector2 position})
      : super(
          position: position,
        );

  @override
  FutureOr<void> onLoad() async {
    debugMode = isDebugModeActivated;
    sprite =
        await Sprite.load('Factions/Knights/Buildings/House/House_Blue.png');
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
}
