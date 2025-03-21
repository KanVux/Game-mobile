import 'package:flame/game.dart';
import 'player.dart';

class PlayerData {
  final String id;
  String character;
  double health;
  double damage;
  double moveSpeed;
  int gold;

  PlayerData({
    required this.id,
    required this.character,
    required this.health,
    required this.damage,
    required this.moveSpeed,
    required this.gold,
  });

  // Create from PocketBase record
  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      id: json['id'],
      character: json['character'] ?? '',
      health: (json['health'] ?? 0).toDouble(),
      damage: (json['damage'] ?? 0).toDouble(),
      moveSpeed: (json['moveSpeed'] ?? 0).toDouble(),
      gold: json['gold'] ?? 0,
    );
  }

  // Convert to JSON for PocketBase
  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'health': health,
      'damage': damage,
      'moveSpeed': moveSpeed,
      'gold': gold,
    };
  }

  // Tạo Player từ PlayerData
  // void applyToPlayer(Player player) {
  //   player.character = character;
  //   player.health = health;
  //   player.damage = damage;
  //   player.moveSpeed = moveSpeed;
  //   // Không cần áp dụng gold vì nó không được sử dụng trong Player
  // }  

  Player createPlayer() {
    return Player(
      character: character,
      health: health,
      damage: damage,
      moveSpeed: moveSpeed,
      position: Vector2.zero(), // hoặc vị trí mặc định khác
    );
  }

  // Tạo PlayerData từ Player
  static PlayerData fromPlayer(Player player,
      {required String id, int gold = 0}) {
    return PlayerData(
      id: id,
      character: player.character,
      health: player.health,
      damage: player.damage,
      moveSpeed: player.moveSpeed,
      gold: gold,
    );
  }
}
