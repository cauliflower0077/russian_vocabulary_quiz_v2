

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/word.dart';

class WordService {
  static const String assetsPath = 'assets/data';

  Future<List<Word>> loadWords() async {
    final List<Word> allWords = [];

    try {
      final manifestContent = await rootBundle.loadString(
        'AssetManifest.json',
      );

      final Map<String, dynamic> manifestMap =
          json.decode(manifestContent);

      final jsonPaths = manifestMap.keys
          .where(
            (path) =>
                path.startsWith(assetsPath) &&
                path.endsWith('.json'),
          )
          .toList();

      for (final path in jsonPaths) {
        try {
          final jsonString = await rootBundle.loadString(path);

          if (jsonString.trim().isEmpty) {
            continue;
          }

          final decoded = json.decode(jsonString);

          if (decoded is! List) {
            continue;
          }

          final words = decoded
              .whereType<Map<String, dynamic>>()
              .map((jsonItem) => Word.fromJson(jsonItem))
              .toList();

          allWords.addAll(words);
        } catch (e) {
          // 個別JSONが壊れていても他を読む
          print('Failed to load $path: $e');
        }
      }
    } catch (e) {
      print('Failed to load asset manifest: $e');
    }

    return allWords;
  }
}

