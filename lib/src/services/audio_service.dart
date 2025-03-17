import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _isMusicReady = false;
  double _volume = 0.5;
  bool _isMuted = false;

  // Initialize the audio service
  Future<void> initialize() async {
    await _loadSettings();
    _applyVolumeSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('musicVolume') ?? 0.5;
    _isMuted = prefs.getBool('isMuted') ?? false;
  }

  // Apply volume settings to all players
  void _applyVolumeSettings() {
    final effectiveVolume = _isMuted ? 0.0 : _volume;
    _musicPlayer.setVolume(effectiveVolume);
  }

  // Play background music
  Future<void> playBackgroundMusic(String assetPath) async {
    if (_isMusicReady) {
      await _musicPlayer.stop();
    }

    await _musicPlayer.setReleaseMode(ReleaseMode.loop); // Looping playback
    await _musicPlayer.setSource(AssetSource(assetPath));
    await _musicPlayer.resume();
    _isMusicReady = true;
    _applyVolumeSettings();
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_isMusicReady) {
      await _musicPlayer.resume();
      _applyVolumeSettings();
    }
  }

  // Set music volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    _applyVolumeSettings();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', _volume);
  }

  // Toggle mute
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    _applyVolumeSettings();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMuted', _isMuted);
  }

  // Getters for current state
  bool get isMuted => _isMuted;
  double get volume => _volume;

  // Dispose resources
  Future<void> dispose() async {
    await _musicPlayer.dispose();
  }
}
