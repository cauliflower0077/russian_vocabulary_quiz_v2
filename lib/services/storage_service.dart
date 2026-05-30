import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String missedKey = 'missed_ids';
  static const String guessedKey = 'guessed_ids';

  // --------------------
  // Missed Words
  // --------------------

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

  static Future<List<int>> getMissedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final list = prefs.getStringList(missedKey);

    return _parseIdList(list);
  }

  static Future<void> addMissedId(int id) async {
    final prefs = await SharedPreferences.getInstance();

    final current = await getMissedIds();

    if (!current.contains(id)) {
      current.add(id);
    }

    await prefs.setStringList(
      missedKey,
      current.map((e) => e.toString()).toList(),
    );
  }

  static Future<void> clearMissedIds() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(missedKey);
  }

  // --------------------
  // Guessed Words
  // --------------------

  static Future<List<int>> getGuessedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final list = prefs.getStringList(guessedKey);

    return _parseIdList(list);
  }

  static Future<void> addGuessedId(int id) async {
    final prefs = await SharedPreferences.getInstance();

    final current = await getGuessedIds();

    if (!current.contains(id)) {
      current.add(id);
    }

    await prefs.setStringList(
      guessedKey,
      current.map((e) => e.toString()).toList(),
    );
  }

  static Future<void> clearGuessedIds() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(guessedKey);
  }
}