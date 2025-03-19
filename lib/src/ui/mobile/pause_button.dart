import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';

class PauseButton extends PositionComponent
    with HasGameRef<Shieldbound>, TapCallbacks {
  PauseButton();

  late final RectangleComponent pauseIcon;
  bool isPressed = false;

  @override
  FutureOr<void> onLoad() async {
    debugMode = isDebugModeActived;

    // Set size and position
    size = Vector2(40, 40);
    position = Vector2(game.windowWidth - 60, 40);

    // Create a simple pause icon using RectangleComponent
    add(RectangleComponent(
      size: Vector2(40, 40),
      paint: Paint()..color = Colors.blue.withOpacity(0.7),
      position: Vector2.zero(),
    ));

    // Add two vertical bars to make a pause icon
    add(RectangleComponent(
      size: Vector2(10, 25),
      paint: Paint()..color = Colors.white,
      position: Vector2(8, 8),
    ));

    add(RectangleComponent(
      size: Vector2(10, 25),
      paint: Paint()..color = Colors.white,
      position: Vector2(22, 8),
    ));

    priority = 200;

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;

    // Visual feedback
    for (final child in children) {
      if (child is RectangleComponent) {
        child.paint.color = child.paint.color.withOpacity(0.5);
      }
    }

    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;

    // Reset visual state
    for (final child in children) {
      if (child is RectangleComponent) {
        child.paint.color = child.paint.color.withOpacity(1.0);
      }
    }

    game.togglePause(); // Toggle pause state
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;

    // Reset visual state
    for (final child in children) {
      if (child is RectangleComponent) {
        child.paint.color = child.paint.color.withOpacity(1.0);
      }
    }

    super.onTapCancel(event);
  }
}
