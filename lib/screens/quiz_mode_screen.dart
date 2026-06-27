import 'package:flutter/material.dart';

import '../models/quiz_mode.dart';
import '../screens/quiz_screen.dart';
import '../services/storage_service.dart';
import '../services/word_service.dart';

class QuizModeScreen extends StatefulWidget {
  final int questionCount;
  final bool russianToEnglish;

  const QuizModeScreen({
    super.key,
    required this.questionCount,
    required this.russianToEnglish,
  });

  @override
  State<QuizModeScreen> createState() =>
      _QuizModeScreenState();
}

class _QuizModeScreenState
    extends State<QuizModeScreen> {
  QuizModeType selectedMode =
      QuizModeType.range;

  bool isLoading = false;

  final TextEditingController startIdController =
      TextEditingController(text: '1');

  final TextEditingController endIdController =
      TextEditingController(text: '100');

  final TextEditingController tagsController =
      TextEditingController();

  @override
  void dispose() {
    startIdController.dispose();
    endIdController.dispose();
    tagsController.dispose();

    super.dispose();
  }

  Future<void> startQuiz() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    QuizMode quizMode;

    switch (selectedMode) {
      case QuizModeType.range:
        quizMode = QuizMode.range(
          startId:
              int.tryParse(startIdController.text) ??
                  1,
          endId:
              int.tryParse(endIdController.text) ??
                  100,
        );
        break;

      case QuizModeType.tags:
        final tags = tagsController.text
            .split(RegExp(r'\s+'))
            .where((e) => e.trim().isNotEmpty)
            .toList();

        quizMode = QuizMode.tags(
          tags: tags,
        );
        break;

      case QuizModeType.missed:
        quizMode = QuizMode.missed();
        break;

      case QuizModeType.guessed:
        quizMode = QuizMode.guessed();
        break;
    }

    final words = await WordService.loadWords();

    if (!mounted) return;

    if (words.isEmpty) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No words loaded'),
        ),
      );

      return;
    }

    // Missed / Guessed モード時に出題対象を絞る
    List filteredWords = words;

    if (quizMode.isMissed) {
      final missedIds =
          await StorageService.getMissedIds();

      filteredWords = words
          .where(
            (word) => missedIds.contains(word.id),
          )
          .toList();
    }

    if (quizMode.isGuessed) {
      final guessedIds =
          await StorageService.getGuessedIds();

      filteredWords = words
          .where(
            (word) => guessedIds.contains(word.id),
          )
          .toList();
    }

    setState(() {
      isLoading = false;
    });

    if (filteredWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No matching words found'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          words: filteredWords.cast(),
          questionCount:
              widget.questionCount,
          russianToEnglish:
              widget.russianToEnglish,
          quizMode: quizMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Mode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile(
              title:
                  const Text('Range Mode'),
              value: QuizModeType.range,
              groupValue: selectedMode,
              onChanged: (value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),

            if (selectedMode ==
                QuizModeType.range)
              Column(
                children: [
                  TextField(
                    controller:
                        startIdController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText: 'Start ID',
                    ),
                  ),
                  TextField(
                    controller:
                        endIdController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText: 'End ID',
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            RadioListTile(
              title:
                  const Text('Tags Mode'),
              value: QuizModeType.tags,
              groupValue: selectedMode,
              onChanged: (value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),

            if (selectedMode ==
                QuizModeType.tags)
              TextField(
                controller: tagsController,
                decoration:
                    const InputDecoration(
                  labelText:
                      '#A1 #動詞 #IT',
                ),
              ),

            const SizedBox(height: 16),

            RadioListTile(
              title:
                  const Text('Missed Only'),
              value: QuizModeType.missed,
              groupValue: selectedMode,
              onChanged: (value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),

            RadioListTile(
              title:
                  const Text('Guessed Only'),
              value: QuizModeType.guessed,
              groupValue: selectedMode,
              onChanged: (value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : startQuiz,
                child: Text(
                  isLoading
                      ? 'Loading...'
                      : 'Start Quiz',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}