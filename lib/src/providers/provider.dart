// filepath: d:\Games\shieldbound\lib\src\providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/services/audio_service.dart';
import 'package:shieldbound/src/models/player.dart';

// Khai báo AudioService dưới dạng Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  // Vì AudioService đã dùng singleton, ta chỉ cần trả về instance hiện có
  final audioService = AudioService();
  // Có thể gọi initialize() nếu chưa được gọi ở nơi khác
  audioService.initialize();
  return audioService;
});

final playerProvider = StateProvider<Player?>((ref) => null);

final playerHealthProvider = StateProvider<int>((ref) {
  final player = ref.watch(playerProvider);
  return player?.health.toInt() ?? 100;
});
