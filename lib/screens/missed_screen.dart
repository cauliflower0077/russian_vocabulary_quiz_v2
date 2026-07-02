import 'package:flutter/material.dart';

import '../models/word.dart';
import '../services/json_export_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

enum MissedSortType {
  count,
  russian,
  english,
  random,
}

class MissedScreen extends StatefulWidget {
  const MissedScreen({super.key});

  @override
  State<MissedScreen> createState() =>
      _MissedScreenState();
}

class _MissedScreenState
    extends State<MissedScreen> {
  List<Word> missedWords = [];

  Map<int, int> missedCounts = {};

  bool isLoading = true;

  MissedSortType sortType =
      MissedSortType.count;

  @override
  void initState() {
    super.initState();

    loadMissedWords();
  }

  Future<void> loadMissedWords() async {
    try {
      final ids =
          await StorageService.getMissedIds();

      final counts =
          await StorageService.getMissedCounts();

      final allWords =
          await WordService.loadWords();

      final idSet = ids.toSet();

      final words = allWords
          .where(
            (word) => idSet.contains(word.id),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        missedWords = words;
        missedCounts = counts;

        applySort();

        isLoading = false;
      });

      debugPrint(
        'MissedScreen: ${ids.length} ids, ${words.length} words shown',
      );
    } catch (e, st) {
      debugPrint(
        'MissedScreen load failed: $e\n$st',
      );

      if (!mounted) return;

      setState(() {
        missedWords = [];
        missedCounts = {};
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load missed words: $e',
          ),
        ),
      );
    }
  }

  void applySort() {
    switch (sortType) {
      case MissedSortType.count:
        missedWords.sort((a, b) {
          return (missedCounts[b.id] ?? 0)
              .compareTo(
            missedCounts[a.id] ?? 0,
          );
        });
        break;

      case MissedSortType.russian:
        missedWords.sort(
          (a, b) => a.ru.compareTo(b.ru),
        );
        break;

      case MissedSortType.english:
        missedWords.sort(
          (a, b) => a.en.compareTo(b.en),
        );
        break;

      case MissedSortType.random:
        missedWords.shuffle();
        break;
    }
  }

  Future<void> exportJson() async {
    final minimumCount =
        await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title:
              const Text('Minimum Count'),
          children: [
            for (final value
                in [1, 2, 3, 5, 10])
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(
                    context,
                    value,
                  );
                },
                child: Text('$value+'),
              ),
          ],
        );
      },
    );

    if (minimumCount == null) return;

    final json =
        JsonExportService.exportWords(
      words: missedWords,
      counts: missedCounts,
      minimumCount: minimumCount,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Missed JSON ($minimumCount+)',
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: SelectableText(
                json,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildSortButton({
    required String text,
    required MissedSortType type,
  }) {
    return ChoiceChip(
      label: Text(text),
      selected: sortType == type,
      onSelected: (_) {
        setState(() {
          sortType = type;
          applySort();
        });
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missed Words'),
        actions: [
          IconButton(
            onPressed: exportJson,
            icon: const Icon(Icons.download),
            tooltip: 'Export JSON',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : missedWords.isEmpty
              ? const Center(
                  child: Text('No missed words'),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          buildSortButton(
                            text: 'Count',
                            type: MissedSortType.count,
                          ),
                          buildSortButton(
                            text: 'Russian',
                            type: MissedSortType.russian,
                          ),
                          buildSortButton(
                            text: 'English',
                            type: MissedSortType.english,
                          ),
                          buildSortButton(
                            text: 'Random',
                            type: MissedSortType.random,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: missedWords.length,
                        itemBuilder: (context, index) {
                          final word = missedWords[index];

                          return Card(
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      word.ru,
                                      style:
                                          const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      word.en,
                                      textAlign:
                                          TextAlign.right,
                                      style:
                                          const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(word.ruTts),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    word.tags.join(' '),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    'Missed: ${missedCounts[word.id] ?? 0}',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.volume_up,
                                ),
                                onPressed: () async {
                                  await TtsService
                                      .speak(
                                    word.ruTts,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}