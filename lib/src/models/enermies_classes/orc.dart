import 'package:flame/components.dart';
import 'package:shieldbound/src/models/enemy.dart';

class Orc extends Enemy {
  Orc({Vector2? position}) // Cho phép position là null
      : super(
          health: 300,
          damage: 10,
          moveSpeed: 80,
          position: position ??
              Vector2.zero(), // Mặc định là (0,0) nếu không truyền vào
          enemyName: 'Orc',
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Có thể thêm logic đặc biệt cho Orc ở đây
  }

}
