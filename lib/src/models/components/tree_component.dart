import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';

class TreeComponent extends SpriteComponent
    with TapCallbacks, CollisionCallbacks, HasGameRef<Shieldbound> {
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
    super.onTapDown(event);
    debugPrint('Tree at position $position tapped.');
    // Bạn có thể thêm hành động tương tác (ví dụ: rung cây, thu hoạch,...) tại đây.
  }
}
