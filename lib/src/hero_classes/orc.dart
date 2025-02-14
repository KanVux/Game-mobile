import 'package:flame/components.dart';
import 'package:shieldbound/src/player.dart';

class Orc extends Player {
  Orc({Vector2? position}) // Cho phép position là null
      : super(
          health: 300,
          damage: 10,
          moveSpeed: 80,
          position: position ??
              Vector2.zero(), // Mặc định là (0,0) nếu không truyền vào
          character: 'Orc',
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Có thể thêm logic đặc biệt cho Orc ở đây
  }

  void specialSkill() {
    moveSpeed *= 1.5;
    Future.delayed(Duration(seconds: 2), () {
      moveSpeed /= 1.5;
    });
  }
}
