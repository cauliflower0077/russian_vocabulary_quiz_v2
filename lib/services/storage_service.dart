import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String missedKey = 'missed_ids';
  static const String guessedKey = 'guessed_ids';

  // v0.3 追加
  static const String missedCountKey = 'missed_counts';
  static const String guessedCountKey = 'guessed_counts';

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('StorageService: SharedPreferences unavailable: $e');
      return null;
    }
  }

  // =====================================================
  // Common Helpers
  // =====================================================

  static List<int> _parseIdList(List<String>? list) {
    if (list == null || list.isEmpty) {
      return [];
    }

    final ids = <int>[];

    for (final value in list) {
      final id = int.tryParse(value.trim());

      if (id != null) {
        ids.add(id);
      }
    }

    return ids;
  }

  static Map<int, int> _parseCountMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map) return {};

      return decoded.map<int, int>((key, value) {
        return MapEntry(
          int.parse(key.toString()),
          (value as num).toInt(),
        );
      });
    } catch (e) {
      debugPrint('StorageService: parse error: $e');
      return {};
    }
  }

  // =====================================================
  // Missed Words
  // =====================================================

  static Future<List<int>> getMissedIds() async {
    final prefs = await _prefs();

    if (prefs == null) return [];

    await prefs.reload();

    final list = prefs.getStringList(missedKey);

    return _parseIdList(list);
  }

  static Future<void> addMissedId(int id) async {
    final prefs = await _prefs();

    if (prefs == null) return;

    final current = await getMissedIds();

    if (!current.contains(id)) {
      current.add(id);
    }

    await prefs.setStringList(
      missedKey,
      current.map((e) => e.toString()).toList(),
    );

    // v0.3
    await incrementMissedCount(id);
  }

  static Future<void> clearMissedIds() async {
    final prefs = await _prefs();

    if (prefs == null) return;

    await prefs.remove(missedKey);
  }

  // =====================================================
  // Guessed Words
  // =====================================================

  static Future<List<int>> getGuessedIds() async {
    final prefs = await _prefs();

    if (prefs == null) return [];

    await prefs.reload();

    final list = prefs.getStringList(guessedKey);

    return _parseIdList(list);
  }

  static Future<void> addGuessedId(int id) async {
    final prefs = await _prefs();

    if (prefs == null) return;

    final current = await getGuessedIds();

    if (!current.contains(id)) {
      current.add(id);
    }

    await prefs.setStringList(
      guessedKey,
      current.map((e) => e.toString()).toList(),
    );

    // v0.3
    await incrementGuessedCount(id);
  }

  static Future<void> clearGuessedIds() async {
    final prefs = await _prefs();

    if (prefs == null) return;

    await prefs.remove(guessedKey);
  }

  // =====================================================
  // Missed Count (v0.3)
  // =====================================================

  static Future<Map<int, int>> getMissedCounts() async {
    final prefs = await _prefs();

    if (prefs == null) return {};

    await prefs.reload();

    final jsonString = prefs.getString(missedCountKey);

    return _parseCountMap(jsonString);
  }

  static Future<void> incrementMissedCount(int id) async {
    final prefs = await _prefs();

    if (prefs == null) return;

    final counts = await getMissedCounts();

    counts[id] = (counts[id] ?? 0) + 1;

    final jsonMap = counts.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    await prefs.setString(
      missedCountKey,
      jsonEncode(jsonMap),
    );
  }

  static Future<void> clearMissedCounts() async {
    final prefs = await _prefs();

    if (prefs == null) return;

    await prefs.remove(missedCountKey);
  }

  // =====================================================
  // Guessed Count (v0.3)
  // =====================================================

  static Future<Map<int, int>> getGuessedCounts() async {
    final prefs = await _prefs();

    if (prefs == null) return {};

    await prefs.reload();

    final jsonString = prefs.getString(guessedCountKey);

    return _parseCountMap(jsonString);
  }

  static Future<void> incrementGuessedCount(int id) async {
    final prefs = await _prefs();

    if (prefs == null) return;

    final counts = await getGuessedCounts();

    counts[id] = (counts[id] ?? 0) + 1;

    final jsonMap = counts.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    await prefs.setString(
      guessedCountKey,
      jsonEncode(jsonMap),
    );
  }

  static Future<void> clearGuessedCounts() async {
    final prefs = await _prefs();

    if (prefs == null) return;

    await prefs.remove(guessedCountKey);
  }
}