import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        await _tts.setSpeechRate(0.4);
        final langResult = await _tts.setLanguage('ru-RU');
        if (langResult != 1) {
          await _tts.setLanguage('ru');
        }
      } else {
        await _tts.setLanguage('ru-RU');
        await _tts.setSpeechRate(0.4);
      }

      _initialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
      // Mark initialized so speak() does not retry init in a loop on Web.
      _initialized = true;
    }
  }

  static Future<void> speak(String text) async {
    try {
      await init();

      if (text.trim().isEmpty) return;

      await _tts.stop();

      final result = await _tts.speak(text);

      if (kIsWeb && result != 1) {
        debugPrint('TTS speak unavailable or silent on web (result: $result)');
      }
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
