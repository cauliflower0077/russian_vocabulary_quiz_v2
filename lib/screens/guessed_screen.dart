import 'package:flutter/material.dart';

import '../models/word.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

enum GuessedSortType {
  count,
  russian,
  english,
  random,
}

class GuessedScreen extends StatefulWidget {
  const GuessedScreen({super.key});

  @override
  State<GuessedScreen> createState() =>
      _GuessedScreenState();
}

class _GuessedScreenState
    extends State<GuessedScreen> {
  List<Word> guessedWords = [];

  Map<int, int> guessedCounts = {};

  bool isLoading = true;

  GuessedSortType sortType =
      GuessedSortType.count;

  @override
  void initState() {
    super.initState();

    loadGuessedWords();
  }

  Future<void> loadGuessedWords() async {
    try {
      final ids =
          await StorageService.getGuessedIds();

      final counts =
          await StorageService.getGuessedCounts();

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
        guessedWords = words;
        guessedCounts = counts;

        applySort();

        isLoading = false;
      });

      debugPrint(
        'GuessedScreen: ${ids.length} ids, ${words.length} words shown',
      );
    } catch (e, st) {
      debugPrint(
        'GuessedScreen load failed: $e\n$st',
      );

      if (!mounted) return;

      setState(() {
        guessedWords = [];
        guessedCounts = {};
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load guess list: $e',
          ),
        ),
      );
    }
  }

  void applySort() {
    switch (sortType) {
      case GuessedSortType.count:
        guessedWords.sort((a, b) {
          return (guessedCounts[b.id] ?? 0)
              .compareTo(
            guessedCounts[a.id] ?? 0,
          );
        });
        break;

      case GuessedSortType.russian:
        guessedWords.sort(
          (a, b) => a.ru.compareTo(b.ru),
        );
        break;

      case GuessedSortType.english:
        guessedWords.sort(
          (a, b) => a.en.compareTo(b.en),
        );
        break;

      case GuessedSortType.random:
        guessedWords.shuffle();
        break;
    }
  }

  Widget buildSortButton({
    required String text,
    required GuessedSortType type,
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
        title: const Text('Guess List'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : guessedWords.isEmpty
              ? const Center(
                  child:
                      Text('No guessed words'),
                )
              : Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          buildSortButton(
                            text: 'Count',
                            type:
                                GuessedSortType.count,
                          ),
                          buildSortButton(
                            text: 'Russian',
                            type:
                                GuessedSortType
                                    .russian,
                          ),
                          buildSortButton(
                            text: 'English',
                            type:
                                GuessedSortType
                                    .english,
                          ),
                          buildSortButton(
                            text: 'Random',
                            type:
                                GuessedSortType
                                    .random,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            guessedWords.length,
                        itemBuilder:
                            (context, index) {
                          final word =
                              guessedWords[index];

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
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 16),
                                  Expanded(
                                    child: Text(
                                      word.en,
                                      textAlign:
                                          TextAlign
                                              .right,
                                      style:
                                          const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight
                                                .bold,
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
                                      height: 8),
                                  Text(word.ruTts),
                                  const SizedBox(
                                      height: 4),
                                  Text(
                                    word.tags.join(
                                        ' '),
                                  ),
                                  const SizedBox(
                                      height: 4),
                                  Text(
                                    'Guessed: ${guessedCounts[word.id] ?? 0}',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.volume_up,
                                ),
                                onPressed:
                                    () async {
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