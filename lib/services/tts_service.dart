import 'package:flutter_tts/flutter_tts.dart';
import '../services/database_service.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final _databaseService = DatabaseService();
  bool _isPlaying = false;
  String? _currentText;

  bool get isPlaying => _isPlaying;

  Future<void> initialize() async {
    final settings = _databaseService.getSettings();
    
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(settings.ttsSpeed);
    await _flutterTts.setPitch(settings.ttsPitch);
    
    if (settings.ttsVoice != null) {
      await _flutterTts.setVoice({"name": settings.ttsVoice!, "locale": "en-US"});
    }

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
    });
  }

  Future<void> speak(String text) async {
    if (_isPlaying) {
      await stop();
    }

    _currentText = text;
    _isPlaying = true;
    await initialize(); // Reload settings
    await _flutterTts.speak(text);
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    _isPlaying = false;
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
    _currentText = null;
  }

  Future<List<dynamic>> getVoices() async {
    return await _flutterTts.getVoices ?? [];
  }

  Future<void> setSpeed(double speed) async {
    await _flutterTts.setSpeechRate(speed);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }
}
