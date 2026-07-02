import 'dart:convert';

import '../models/word.dart';

class JsonExportService {
  const JsonExportService._();

  /// wordsをJSONへ変換する
  ///
  /// minimumCount:
  /// nullなら全件出力
  /// 1なら1回以上
  /// 3なら3回以上...
  static String exportWords({
    required List<Word> words,
    required Map<int, int> counts,
    int? minimumCount,
  }) {
    final filtered = words.where((word) {
      if (minimumCount == null) {
        return true;
      }

      return (counts[word.id] ?? 0) >= minimumCount;
    }).toList();

    final jsonList = filtered
        .map(
          (word) => {
            'id': word.id,
            'ru': word.ru,
            'ru_tts': word.ruTts,
            'en': word.en,
            'category': word.category,
            'tags': word.tags,
          },
        )
        .toList();

    const encoder = JsonEncoder.withIndent('  ');

    return encoder.convert(jsonList);
  }
}