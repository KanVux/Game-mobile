import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/models/player_data.dart';
import 'package:shieldbound/src/models/shop_item.dart';

// service này sẽ đảm nhận vai trò của thao tác với cơ sở dữ liệu để đơn giản hóa không cần tạo player_data_service và shop_item_service

class PocketBaseService {
  // Singleton pattern
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  // Replace with your PocketBase URL
  final String baseUrl = 'http://10.0.2.2:8090'; // URL for Android emulator
  late final PocketBase pb;

  // Initialize the PocketBase client
  Future<void> initialize() async {
    pb = PocketBase(baseUrl);
    // Add any initialization logic here
  }

  Future<void> logConnectionTest() async {
    try {
      // Try to get server health info
      final health = await pb.health.check();
      print('PocketBase connection successful! Server status: ${health.code}');
    } catch (e) {
      print('PocketBase connection failed: $e');
    }
  }

  // Get the PocketBase client
  PocketBase get client => pb;

  // PLAYER METHODS

  // Fetch a player by ID
  Future<PlayerData?> getPlayer(String id) async {
    try {
      final record = await pb.collection('players').getOne(id);
      return PlayerData.fromJson(record.toJson());
    } catch (e) {
      print('Error fetching player: $e');
      return null;
    }
  }

  // Create a new player
  Future<PlayerData?> createPlayer(PlayerData player) async {
    try {
      final record =
          await pb.collection('players').create(body: player.toJson());
      return PlayerData.fromJson(record.toJson());
    } catch (e) {
      print('Error creating player: $e');
      return null;
    }
  }

  // Update an existing player
  Future<PlayerData?> updatePlayer(PlayerData player) async {
    try {
      final record = await pb
          .collection('players')
          .update(player.id, body: player.toJson());
      return PlayerData.fromJson(record.toJson());
    } catch (e) {
      print('Error updating player: $e');
      return null;
    }
  }

  // SHOP ITEM METHODS

  // Fetch all shop items
  Future<List<ShopItem>> getAllShopItems() async {
    try {
      final response =
          await pb.collection('items').getList(page: 1, perPage: 50);
      return response.items
          .map((item) => ShopItem.fromJson(item.toJson()))
          .toList();
    } catch (e) {
      print('Error fetching shop items: $e');
      return [];
    }
  }

  // Get a specific shop item
  Future<ShopItem?> getShopItem(String id) async {
    try {
      final record = await pb.collection('items').getOne(id);
      return ShopItem.fromJson(record.toJson());
    } catch (e) {
      print('Error fetching shop item: $e');
      return null;
    }
  }
}

// Provider for PocketBase service
final pocketbaseServiceProvider = Provider<PocketBaseService>((ref) {
  final service = PocketBaseService();
  service.initialize();
  return service;
});
