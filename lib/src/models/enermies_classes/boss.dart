import 'package:flame/extensions.dart';
import 'package:shieldbound/src/models/enemy.dart';

class Boss extends Enemy{
  Boss({required Vector2 position}) : super(
    health: 1000,
    damage: 50,
    moveSpeed: 50,
    position: position,
    enemyName: 'Boss',
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load sprite, animation, sound, etc.
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update AI, movement, etc.
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render boss sprite, health bar, etc.
  }
}