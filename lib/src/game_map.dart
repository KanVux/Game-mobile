import 'dart:async';

import 'package:flame/components.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/enemy.dart';
import 'package:shieldbound/src/player.dart';
import 'package:flame_tiled/flame_tiled.dart';

class GameMap extends World with HasGameRef<Shieldbound> {
  final String mapName; // Tên của map
  final Player player; //  Khai báo một player cho một map
  final Enemy enemy;
  final Vector2 gridSize = Vector2.all(16); // Grid size của map 16x16 ô
  GameMap({required this.mapName, required this.player, required this.enemy});

  @override
  FutureOr<void> onLoad() async {
    // Được chạy khi load game

    late TiledComponent map; // Khai báo map
    List<CollisionBlock> collisionBlocks = [];
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
          case 'Enemy':
            enemy.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(enemy);
            break;
        }
      }
    }
    // Lớp thứ II: lớp cho vùng va chạm (Collision Layer)
    final collisionLayer = map.tileMap.getLayer<ObjectGroup>('Collision');
    if (collisionLayer != null) {
      for (final block in collisionLayer.objects) {
        switch (block.class_) {
          // Trường hợp block có cơ chế đặc biệt

          // Trường hợp mặc định
          default:
            final collisionBlock = CollisionBlock(
              positioin: Vector2(block.x, block.y),
              size: Vector2(block.width, block.height),
            );
            collisionBlocks.add(collisionBlock);
            add(collisionBlock);
            break;
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Lấy danh sách các entity có thể thay đổi thứ tự render
    final sortedChildren = children
        .whereType<PositionComponent>()
        .toList() // Chuyển thành danh sách có thể sắp xếp
      ..sort((a, b) => a.y.compareTo(b.y)); // Sắp xếp theo y

    // Cập nhật thứ tự render
    for (var i = 0; i < sortedChildren.length; i++) {
      sortedChildren[i].priority = i;
    }
  }
}
