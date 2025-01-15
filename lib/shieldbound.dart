import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:shieldbound/src/game_map.dart';
import 'package:shieldbound/src/player.dart';

class Shieldbound extends FlameGame with HasKeyboardHandlerComponents {
  late final CameraComponent cam;
  final double windowWidth = 640;
  final double windowHeight = 360;

  Player player = Player(character: 'Soldier');

  Shieldbound() : super();

  @override
  FutureOr<void> onLoad() async {
    // Load toàn bộ ảnh trong assets vào Cache
    // TODO: Kiểm tra ở đây nếu bị giảm hiệu xuất
    // (nếu có dấu hiệu bị giảm performance thì chuyển lại chỉ load các image cần thiết)
    await images.loadAllImages();

    // Tạo một map
    final gameMap = GameMap(
      mapName: 'map_01',
      player: player,
    );
    // Tạo góc camera với:
    // world: gameMap
    // width: chiều rộng cửa sổ game
    // height: chiều cao cửa sổ game
    cam = CameraComponent.withFixedResolution(
      world: gameMap,
      width: windowWidth,
      height: windowHeight,
    );

    // Ghim camera vào phía trên bên trái vị trí (0, 0) (Tính góc trên bên trái là gốc tọa độ)
    cam.viewfinder.anchor = Anchor.topLeft;
    // Độ ưu tiên của cam
    cam.priority = 0;

    addAll([cam, gameMap]);
    return super.onLoad();
  }
}
