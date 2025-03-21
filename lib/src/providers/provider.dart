// filepath: lib/src/providers/provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/services/audio_service.dart';
import 'package:shieldbound/src/models/player.dart';
import 'package:shieldbound/src/models/player_data.dart';
import 'package:shieldbound/src/models/shop_item.dart';
import 'package:shieldbound/src/services/pocketbase_service.dart';

// Declare AudioService as Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  // Since AudioService is a singleton, we just need to return the existing instance
  final audioService = AudioService();
  // Can call initialize() if not called elsewhere
  audioService.initialize();
  return audioService;
});

// Player and game state providers
final playerProvider = StateProvider<Player?>((ref) => null);

final playerHealthProvider = StateProvider<int>((ref) {
  final player = ref.watch(playerProvider);
  return player?.health.toInt() ?? 100;
});

// Player data provider (from PocketBase)
final playerDataProvider = StateProvider<PlayerData?>((ref) => null);

// Player gold provider
final playerGoldProvider = StateProvider<int>((ref) {
  final playerData = ref.watch(playerDataProvider);
  return playerData?.gold ?? 0;
});

// Shop item providers
final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  final pocketBaseService = ref.read(pocketbaseServiceProvider);
  return await pocketBaseService.getAllShopItems();
});

// Current player ID provider (for saving/loading)
final currentPlayerIdProvider = StateProvider<String?>((ref) => null);
