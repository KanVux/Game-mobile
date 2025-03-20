import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  double _volume = 0.5;
  double _sfxVolume = 0.7;
  bool _isMuted = false;

  double get volume => _volume;
  double get sfxVolume => _sfxVolume;
  bool get isMuted => _isMuted;

  /// Khởi tạo AudioService: load các cài đặt từ SharedPreferences và khởi tạo background music
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('musicVolume') ?? 0.5;
    _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.7;
    _isMuted = prefs.getBool('isMuted') ?? false;

    // Khởi tạo background music
    FlameAudio.bgm.initialize();
    await _applyVolumeSettings();
  }

  /// Áp dụng volume cho background music thông qua audioPlayer của Bgm
  Future<void> _applyVolumeSettings() async {
    final effectiveVolume = _isMuted ? 0.0 : _volume;
    // Cập nhật volume ngay trên audioPlayer
    await FlameAudio.bgm.audioPlayer.setVolume(effectiveVolume);
  }

  /// Phát background music từ asset, mỗi lần gọi sẽ phát một instance mới
  Future<void> playBackgroundMusic(String assetPath) async {
    if (_isMuted) return;
    await FlameAudio.bgm.stop();
    await FlameAudio.bgm.play(assetPath, volume: _volume);
  }

  /// Dừng background music
  Future<void> stopBackgroundMusic() async {
    await FlameAudio.bgm.stop();
  }

  /// Phát sound effect từ asset (volume được áp dụng qua _sfxVolume)
  Future<void> playSoundEffect(String assetPath) async {
    if (_isMuted) return;
    await FlameAudio.play(assetPath, volume: _sfxVolume);
  }

  /// Cài đặt volume cho background music (toàn bộ game)
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', _volume);
    await _applyVolumeSettings();
  }

  /// Cài đặt volume cho sound effects
  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfxVolume', _sfxVolume);
  }

  /// Toggle mute và cập nhật volume ngay lập tức
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMuted', _isMuted);
    await _applyVolumeSettings();
  }
}
