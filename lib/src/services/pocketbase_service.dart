import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PocketBaseService {
  // Singleton pattern
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  // Replace with your PocketBase URL
  final String baseUrl = 'http://10.0.2.2:8090'; // đây là URL đối với máy ảo ANDROID, các máy khác sẽ có URL khác
  late final PocketBase pb;

  // Initialize the PocketBase client
  Future<void> initialize() async {
    pb = PocketBase(baseUrl);
    // Add any initialization logic here
  }

  Future<void> logConnectionTest() async {
    try {
      // Thử lấy thông tin server health
      final health = await pb.health.check();
      print('PocketBase connection successful! Server status: ${health.code}');
    } catch (e) {
      print('PocketBase connection failed: $e');
    }
  }

  // Get the PocketBase client
  PocketBase get client => pb;
}

// Provider for PocketBase service
final pocketbaseServiceProvider = Provider<PocketBaseService>((ref) {
  final service = PocketBaseService();
  service.initialize();
  return service;
});
