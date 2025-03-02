import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/models/interactable.dart';

class TreeComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<Shieldbound>
    implements Interactable {
  TreeComponent({required Vector2 position}) : super(position: position);

  @override
  FutureOr<void> onLoad() async {
    debugMode = isDebugModeActived;
    // Load sprite của cây (đảm bảo file sprite được khai báo trong pubspec.yaml)
    sprite = await Sprite.load('Resources/Trees/Tree.png');
    // Kích thước của cây, bạn điều chỉnh cho phù hợp
    size = Vector2(150, 150);
    // Đặt anchor là bottomCenter để điểm "gốc" nằm ở đáy giữa sprite
    anchor = Anchor.bottomCenter;
    add(CircleHitbox(radius: 10, position: Vector2(65, 120)));
    // Thêm CircleHitbox để collision chặn người chơi đi xuyên qua gốc cây.
    // Vì anchor của cây là bottomCenter, vị trí (0, 0) tương đối của hitbox sẽ trùng với gốc cây

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    debugPrint('Tree at position $position tapped.');
    //Thêm hành động tương tác (ví dụ: rung cây, thu hoạch,...).
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    // TODO: implement onLongTapDown
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // TODO: implement onTapCancel
  }

  @override
  void onTapUp(TapUpEvent event) {
    // TODO: implement onTapUp
  }
}
