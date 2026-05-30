// lib/screens/result_screen.dart

import 'package:flutter/material.dart';

import '../models/word.dart';

class ResultScreen extends StatelessWidget {
  final int correctCount;

  final int totalQuestions;

  final List<Word> wrongWords;

  final List<Word> guessedWords;

  const ResultScreen({
    super.key,
    required this.correctCount,
    required this.totalQuestions,
    required this.wrongWords,
    required this.guessedWords,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy =
        ((correctCount / totalQuestions) * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accuracy: $accuracy%',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Correct: $correctCount',
              style: const TextStyle(fontSize: 20),
            ),

            Text(
              'Wrong: ${totalQuestions - correctCount}',
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 32),

            const Text(
              'Wrong Words',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (wrongWords.isEmpty)
              const Text('None')
            else
              ...wrongWords.map(
                (word) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${word.ru} - ${word.en}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            const Text(
              'Guessed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (guessedWords.isEmpty)
              const Text('None')
            else
              ...guessedWords.map(
                (word) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${word.ru} - ${word.en}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}