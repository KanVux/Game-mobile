import 'package:flame/game.dart';
import 'package:shieldbound/src/models/hero_classes/soilder.dart';
import 'package:shieldbound/src/models/hero_classes/wizard.dart';
import 'player.dart';

class PlayerData {
  final String id;
  String character;
  double health;
  double maxHealth;
  double damage;
  double moveSpeed;
  int gold;

  PlayerData({
    required this.id,
    required this.character,
    required this.health,
    required this.maxHealth,
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
      maxHealth: (json['maxHealth'] ?? 0).toDouble(),
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
      'maxHealth': maxHealth,
      'damage': damage,
      'moveSpeed': moveSpeed,
      'gold': gold,
    };
  }

  // Create a player instance from PlayerData
  Player createPlayer(Vector2 position) {
    // This is where we instantiate the appropriate player class based on the character
    if (character == 'Soldier') {
      return Soldier(
        position: position,
      );
    } else if (character == 'Wizard') {
      return Wizard(
        position: position,
      );
    }

    // Default to Soldier if character type is not recognized
    return Soldier(
      position: position,
    );
  }

  // Create PlayerData from a Player instance
  static PlayerData fromPlayer(Player player,
      {required String id, int gold = 0}) {
    return PlayerData(
      id: id,
      character: player.character,
      health: player.health,
      maxHealth: player.maxHealth,
      damage: player.damage,
      moveSpeed: player.moveSpeed,
      gold: gold,
    );
  }
}
