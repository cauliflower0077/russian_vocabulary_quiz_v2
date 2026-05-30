// lib/services/word_service.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/word.dart';

class WordService {
  static const String dataPrefix = 'assets/data/';

  static const List<String> fallbackJsonPaths = [
    'assets/data/words_a1.json',
    'assets/data/words_a2.json',
    'assets/data/words_verbs.json',
    'assets/data/words_food.json',
    'assets/data/words_misc.json',
  ];

  /// Discovers bundled JSON under [dataPrefix] (Web: AssetManifest.bin via API).
  static Future<List<String>> _resolveJsonPaths() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final paths = manifest
          .listAssets()
          .where((key) => key.startsWith(dataPrefix) && key.endsWith('.json'))
          .toList()
        ..sort();
      if (paths.isNotEmpty) {
        return paths;
      }
    } catch (e) {
      debugPrint('WordService: AssetManifest API failed ($e)');
    }

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifest = json.decode(manifestContent) as Map<String, dynamic>;
      final paths = manifest.keys
          .where((key) => key.startsWith(dataPrefix) && key.endsWith('.json'))
          .toList()
        ..sort();
      if (paths.isNotEmpty) {
        return paths;
      }
    } catch (e) {
      debugPrint('WordService: AssetManifest.json unavailable ($e)');
    }

    return fallbackJsonPaths;
  }

  static Future<List<Word>> loadWords() async {
    final paths = await _resolveJsonPaths();
    final List<Word> allWords = [];

    for (final path in paths) {
      try {
        final jsonString = await rootBundle.loadString(path);

        if (jsonString.trim().isEmpty) {
          continue;
        }

        final decoded = json.decode(jsonString);

        if (decoded is! List) {
          debugPrint('WordService: $path is not a JSON array');
          continue;
        }

        final words = decoded
            .whereType<Map<String, dynamic>>()
            .map(Word.fromJson)
            .toList();

        allWords.addAll(words);
        debugPrint('WordService: loaded ${words.length} from $path');
      } catch (e, st) {
        debugPrint('WordService: failed to load $path: $e\n$st');
      }
    }

    if (allWords.isEmpty) {
      debugPrint(
        'WordService: 0 words. Ensure pubspec.yaml has "assets/data/" and run flutter pub get, then restart (not hot reload only).',
      );
    }

    return allWords;
  }
}
