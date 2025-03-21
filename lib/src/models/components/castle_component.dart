import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/attack/hero/soldier/sword_slash_attack.dart';
import 'package:shieldbound/src/models/interactable.dart';
import 'package:shieldbound/src/providers/provider.dart';
import 'package:shieldbound/src/services/pocketbase_service.dart';

class CastleComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<Shieldbound>
    implements Interactable {
  CastleComponent({required Vector2 position})
      : super(
          position: position,
        );

  double health = 500;
  bool isDestroyed = false;

  // Add cooldown tracking
  bool canTakeDamage = true;
  Timer? damageTimer;
  final double damageCooldown = 0.5; // Half second between damage ticks

  @override
  FutureOr<void> onLoad() async {
    debugMode = isDebugModeActivated;
    sprite =
        await Sprite.load('Factions/Knights/Buildings/Castle/Castle_Red.png');
    size = Vector2(100, 150);
    anchor = Anchor.center;
    add(RectangleHitbox(
      position: Vector2(18, size.y / 2),
      size: Vector2(65, 55),
    )
      ..debugMode = isDebugModeActivated
      ..debugColor = Colors.yellow);
    return super.onLoad();
  }

// Add this private method to award gold to the player

  void _awardGoldToPlayer() {
    try {
      // Award different gold amounts based on enemy type
      int goldAmount = 500; // Base gold amount

      // Get the player data from the provider
      final playerData = game.ref.read(playerDataProvider);
      if (playerData != null) {
        // Add gold to player
        playerData.gold += goldAmount;

        // Update the gold provider
        game.ref.read(playerGoldProvider.notifier).state = playerData.gold;

        game.ref.read(playerDataProvider.notifier).state = playerData;

        // Save to PocketBase in the background
        Future(() async {
          final pocketbaseService = game.ref.read(pocketbaseServiceProvider);
          await pocketbaseService.updatePlayer(playerData);
        });

        debugPrint("Awarded $goldAmount gold to player");
      }
    } catch (e) {
      debugPrint("Error awarding gold: $e");
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is SwordSlashAttack && canTakeDamage) {
      // Only take damage if not on cooldown
      takedamge(other.damage * 10);
      canTakeDamage = false;

      // Set cooldown timer
      damageTimer?.stop();
      damageTimer = Timer(
        damageCooldown,
        onTick: () {
          canTakeDamage = true;
          damageTimer = null;
        },
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update damage timer
    damageTimer?.update(dt);
  }

  @override
  void onRemove() {
    damageTimer?.stop();
    super.onRemove();
  }

  void takedamge(double damageTaken) async {
    if (health > 0) {
      health -= damageTaken;
      debugPrint('Castle health: $health'); // Add debug logging
    }

    if (health <= 0 && !isDestroyed) {
      isDestroyed = true; // Set this first to prevent multiple spawns

      // Award gold
      _awardGoldToPlayer();

      // Update sprite
      sprite = await Sprite.load(
          'Factions/Knights/Buildings/Castle/Castle_Destroyed.png');

      // Spawn boss with offset to prevent collision
      final spawnPosition = position + Vector2(100, 0); // Offset to the right
      debugPrint(
          'Attempting to spawn boss at: ${spawnPosition.x}, ${spawnPosition.y}');
    }
  }
}
