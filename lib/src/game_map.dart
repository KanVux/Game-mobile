import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/collision_block.dart';
import 'package:shieldbound/src/models/components/house_component.dart';
import 'package:shieldbound/src/models/player.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/providers/enemy_provider.dart';
import 'package:shieldbound/src/models/enermies_classes/orc.dart';

import 'models/components/tree_component.dart';

class GameMap extends World with HasGameRef<Shieldbound> {
  late final double mapWidth;
  late final double mapHeight;

  // Tạo 2 container:
  // - backgroundLayer chứa bản đồ nền
  // - dynamicLayer chứa tất cả các entity động (player, enemy, collision, cây, …)
  late final PositionComponent backgroundLayer;
  late final PositionComponent dynamicLayer;

  final String mapName; // Tên của map (ví dụ: Home.tmx)
  final Player player; // Player được spawn trên map
  final Vector2 gridSize = Vector2.all(16); // Kích thước mỗi tile: 16x16

  GameMap({required this.mapName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    // 1. Tạo các container layer
    backgroundLayer = PositionComponent()..priority = 0;
    dynamicLayer = PositionComponent()..priority = 1;
    addAll([backgroundLayer, dynamicLayer]);

    // 2. Load map từ file Tiled
    late TiledComponent map;
    List<CollisionBlock> collisionBlocks = [];
    try {
      map = await TiledComponent.load('$mapName.tmx', gridSize);
      backgroundLayer.add(map);
    } catch (e, stackTrace) {
      debugPrint('Error loading Tiled map: $e');
      debugPrint('$stackTrace');
    }
    if (game.playSounds) {
      // FlameAudio.play('musics/2.mp3', volume: game.volume * 0.1);
    }
    // 3. Tính kích thước map
    mapWidth = map.tileMap.map.width * map.tileMap.map.tileWidth.toDouble();
    mapHeight = map.tileMap.map.height * map.tileMap.map.tileHeight.toDouble();
    debugPrint('Map width: $mapWidth, height: $mapHeight');




    // 4. Lớp Collision: thêm vùng va chạm
    final collisionLayerData = map.tileMap.getLayer<ObjectGroup>('Collision');
    if (collisionLayerData != null) {
      for (final block in collisionLayerData.objects) {
        final collisionBlock = CollisionBlock(
          positioin: Vector2(block.x, block.y),
          size: Vector2(block.width, block.height),
        );
        collisionBlocks.add(collisionBlock);
        dynamicLayer.add(collisionBlock);
      }
    }

    // 5. Lớp SpawnPoint: spawn Player và Enemy
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>('SpawnPoint');
    if (spawnPointLayer != null) {
      // Sử dụng một container Riverpod duy nhất (lưu ý: trong ứng dụng thật nên lấy từ ProviderScope đã được bọc widget gốc)
      final container = ProviderContainer();
      final enemyController = container.read(enemySpawnProvider.notifier);

      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            // Giữ player với anchor topLeft theo yêu cầu
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.anchor = Anchor.topLeft;
            dynamicLayer.add(player);
            break;
          case 'Enemy':
            // Sử dụng cùng 1 spawn point để spawn nhiều enemy qua provider
            enemyController.trySpawnEnemy(
              (position) => Orc(position: position),
              Vector2(spawnPoint.x, spawnPoint.y),
            );
            break;
        }
      }
      // Sau khi xử lý spawn points, thêm các enemy từ provider vào dynamicLayer.
      // (Lưu ý: với hệ thống thay đổi state, bạn cần update dynamicLayer khi state provider thay đổi.)
      final enemyList = container.read(enemySpawnProvider);
      for (final enemy in enemyList) {
        // Đảm bảo enemy có anchor phù hợp
        enemy.anchor = Anchor.topLeft;
        enemy.collisionBlocks = collisionBlocks;
        dynamicLayer.add(enemy);
      }
    }


    // 6. Lớp Interactables: thêm các đối tượng tương tác (ví dụ: Tree)
    final interactableLayer =
        map.tileMap.getLayer<ObjectGroup>('Interactables');
    if (interactableLayer != null) {
      for (final obj in interactableLayer.objects) {
        switch (obj.class_) {
          case 'Tree':
            final tree = TreeComponent(position: Vector2(obj.x, obj.y));
            // Đối với cây, ta đặt anchor là bottomCenter để tính "gốc" của cây chính xác
            tree.anchor = Anchor.bottomCenter;
            dynamicLayer.add(tree);
            break;
          case 'House':
            final house = HouseComponent(position: Vector2(obj.x, obj.y));
            dynamicLayer.add(house);
            break;
        }
      }
    }

    //truyền danh sách collisionBlocks cho player
    player.collisionBlocks = collisionBlocks;
    
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Cập nhật thứ tự render cho các entity trong dynamicLayer dựa trên "điểm chân" (base)
    // Với anchor topLeft: base = position.y + size.y
    // Với anchor bottomCenter: base = position.y (vì anchor.y = 1)
    double getBase(PositionComponent comp) {
      // Nếu comp.anchor là topLeft (0,0), base = position.y + size.y;
      // Nếu comp.anchor khác, tính chung theo: base = position.y + size.y * (1 - comp.anchor.y)
      return comp.position.y + comp.size.y * (1 - comp.anchor.y);
    }

    final sortedEntities = dynamicLayer.children
        .whereType<PositionComponent>()
        .toList()
      ..sort((a, b) => getBase(a).compareTo(getBase(b)));

    // Cập nhật priority dựa theo thứ tự sắp xếp
    int prio = 0;
    for (final comp in sortedEntities) {
      comp.priority = prio;
      prio++;
    }
  }
}
