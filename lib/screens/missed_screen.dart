// lib/screens/missed_screen.dart

import 'package:flutter/material.dart';

import '../models/word.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

class MissedScreen extends StatefulWidget {
  const MissedScreen({super.key});

  @override
  State<MissedScreen> createState() =>
      _MissedScreenState();
}

class _MissedScreenState
    extends State<MissedScreen> {
  List<Word> missedWords = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadMissedWords();
  }

  Future<void> loadMissedWords() async {
    try {
      final ids = await StorageService.getMissedIds();
      final allWords = await WordService.loadWords();
      final idSet = ids.toSet();

      final words = allWords
          .where((word) => idSet.contains(word.id))
          .toList();

      if (!mounted) return;

      setState(() {
        missedWords = words;
        isLoading = false;
      });

      debugPrint(
        'MissedScreen: ${ids.length} ids, ${words.length} words shown',
      );
    } catch (e, st) {
      debugPrint('MissedScreen load failed: $e\n$st');
      if (!mounted) return;

      setState(() {
        missedWords = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load missed words: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missed Words'),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : missedWords.isEmpty
              ? const Center(
                  child:
                      Text('No missed words'),
                )
              : ListView.builder(
                  itemCount:
                      missedWords.length,

                  itemBuilder:
                      (context, index) {
                    final word =
                        missedWords[index];

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