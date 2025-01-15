import 'package:flame/components.dart';
import 'package:shieldbound/main.dart';

class CollisionBlock extends PositionComponent {
  // ignore: use_super_parameters
  CollisionBlock({
    positioin,
    size,
  }) : super(
          position: positioin,
          size: size,
        ) {
    debugMode = isDebugModeActived;
  }
}
