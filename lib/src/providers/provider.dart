// filepath: d:\Games\shieldbound\lib\src\providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/services/audio_service.dart';

// Khai báo AudioService dưới dạng Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  // Vì AudioService đã dùng singleton, ta chỉ cần trả về instance hiện có
  final audioService = AudioService();
  // Có thể gọi initialize() nếu chưa được gọi ở nơi khác
  audioService.initialize();
  return audioService;
});
