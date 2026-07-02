// lib/services/json_export_service.dart

import 'dart:convert';

import '../models/word.dart';

class JsonExportService {
  const JsonExportService._();

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

    const encoder = JsonEncoder.withIndent('  ');

    return encoder.convert(
      filtered.map((word) => word.toJson()).toList(),
    );
  }
}