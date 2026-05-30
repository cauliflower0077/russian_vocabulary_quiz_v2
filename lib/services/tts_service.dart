import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      await _tts.setLanguage('ru-RU');

      // 少し遅めの方が聞き取りやすい
      await _tts.setSpeechRate(0.4);

      _initialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  static Future<void> speak(String text) async {
    try {
      await init();

      if (text.trim().isEmpty) return;

      await _tts.stop();

      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}