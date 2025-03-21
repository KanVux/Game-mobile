import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CustomHitbox {
  final Vector2 offset;
  final Vector2 size;

  CustomHitbox({required this.offset, required this.size});
}


class CustomHitboxComponent extends PositionComponent {
  CustomHitbox hitbox;

  CustomHitboxComponent({required this.hitbox});

}