import 'dart:async';

import 'package:flame/components.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/models/player.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'models/enermies_classes/orc.dart';

class GameMap extends World with HasGameRef<Shieldbound> {
  late final double mapWidth;
  late final double mapHeight;

  final String mapName; // Tên của map
  final Player player; //  Khai báo một player cho một map
  final Vector2 gridSize = Vector2.all(16); // Grid size của map 16x16 ô
  GameMap({required this.mapName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    // Được chạy khi load game

    late TiledComponent map; // Khai báo map
    List<CollisionBlock> collisionBlocks = [];
    try {
      map = await TiledComponent.load(
        '$mapName.tmx',
        gridSize,
      ); // Load map có tên $mapName có kích thước gridSize vào map

      add(map);
    } catch (e, stackTrace) {
      print('Error loading Tiled map: $e');
      print(stackTrace);
    }

    mapWidth = map.tileMap.map.width * map.tileMap.map.tileWidth.toDouble();
    mapHeight = map.tileMap.map.height * map.tileMap.map.tileHeight.toDouble();

    print(mapWidth);
    print(mapHeight);
    // Thêm các lớp (Layers) cho một map
    // Lớp thứ I: Lớp cho điểm hồi sinh (Spawn point)
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>(
        'SpawnPoint'); // Lấy một nhóm object từ lớp 'SpawnPoint'
    // Kiểm tra sự tồn tại của Layer, làm hết cho các layer được thêm vào
    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Enemy': // Spawn Enemy dựa vào name
            final enemyClassMap = {
              'Orc': () => Orc(position: Vector2(spawnPoint.x, spawnPoint.y)),
              // Sau này có thể thêm nhiều loại enemy khác vào đây
            };

            if (enemyClassMap.containsKey(spawnPoint.name)) {
              final enemyInstance = enemyClassMap[spawnPoint.name]!();
              add(enemyInstance);
            } else {
              print('Không tìm thấy enemy với name: ${spawnPoint.name}');
            }
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
