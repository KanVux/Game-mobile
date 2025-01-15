import 'dart:async';

import 'package:flame/components.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/player.dart';
import 'package:flame_tiled/flame_tiled.dart';

class GameMap extends World with HasGameRef<Shieldbound> {
  final String mapName; // Tên của map
  final Player player; //  Khai báo một player cho một map
  final Vector2 gridSize = Vector2.all(16); // Grid size của map 16x16 ô

  GameMap({required this.mapName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    // Được chạy khi load game
    late TiledComponent map; // Khai báo map

    map = await TiledComponent.load(
      '$mapName.tmx',
      gridSize,
    ); // Load map có tên $mapName có kích thước gridSize vào map

    add(map); // Thêm map vào game

    // Thêm các lớp (Layers) cho một map
    // Lớp thứ I: Lớp cho điểm hồi sinh (Spawn point)
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>(
        'SpawnPoint'); // Lấy một nhóm object từ lớp 'SpawnPoint'
    // Kiểm tra sự tồn tại của Layer, làm hết cho các layer được thêm vào
    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        // Duyệt qua các object nhận được từ layer này
        switch (spawnPoint.class_) {
          case 'Player': // Nếu lớp (Class) của object lấy được là Player thì spawn player vào vị trí của spawnPoint
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
        }
      }
    }
    return super.onLoad();
  }
}
