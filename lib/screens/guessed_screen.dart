// lib/screens/guessed_screen.dart

import 'package:flutter/material.dart';

import '../models/word.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

class GuessedScreen extends StatefulWidget {
  const GuessedScreen({super.key});

  @override
  State<GuessedScreen> createState() =>
      _GuessedScreenState();
}

class _GuessedScreenState
    extends State<GuessedScreen> {
  List<Word> guessedWords = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadGuessedWords();
  }

  Future<void> loadGuessedWords() async {
    try {
      final ids = await StorageService.getGuessedIds();
      final allWords = await WordService.loadWords();
      final idSet = ids.toSet();

      final words = allWords
          .where((word) => idSet.contains(word.id))
          .toList();

      if (!mounted) return;

      setState(() {
        guessedWords = words;
        isLoading = false;
      });

      debugPrint(
        'GuessedScreen: ${ids.length} ids, ${words.length} words shown',
      );
    } catch (e, st) {
      debugPrint('GuessedScreen load failed: $e\n$st');
      if (!mounted) return;

      setState(() {
        guessedWords = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load guess list: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess List'),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : guessedWords.isEmpty
              ? const Center(
                  child:
                      Text('No guessed words'),
                )
              : ListView.builder(
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
                              width: 16,
                            ),

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
                              height: 8,
                            ),

                            Text(word.ruTts),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              word.tags.join(
                                ' ',
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
    );
  }
}