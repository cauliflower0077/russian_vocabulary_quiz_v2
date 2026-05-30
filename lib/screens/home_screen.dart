// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

import '../services/word_service.dart';

import 'quiz_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedQuestionCount = 10;

  bool russianToEnglish = true;

  Future<void> startQuiz() async {
    final words = await WordService.loadWords();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          words: words,
          questionCount: selectedQuestionCount,
          russianToEnglish: russianToEnglish,
        ),
      ),
    );
  }

  void openStudyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StudyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Russian Vocabulary Quiz',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Question Count',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,

              children:
                  [10, 20, 50, 100].map((count) {
                return ChoiceChip(
                  label: Text('$count'),

                  selected:
                      selectedQuestionCount ==
                          count,

                  onSelected: (_) {
                    setState(() {
                      selectedQuestionCount =
                          count;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            const Text(
              'Mode',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,

              title: const Text(
                'Russian → English',
              ),

              value: true,

              groupValue: russianToEnglish,

              onChanged: (value) {
                setState(() {
                  russianToEnglish = value!;
                });
              },
            ),

            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,

              title: const Text(
                'English → Russian',
              ),

              value: false,

              groupValue: russianToEnglish,

              onChanged: (value) {
                setState(() {
                  russianToEnglish = value!;
                });
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                onPressed: startQuiz,

                child: const Text(
                  'Start Quiz',

                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton(
                onPressed: () {},

                child: const Text(
                  'Missed Words',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton(
                onPressed: () {},

                child: const Text(
                  'Guess List',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton(
                onPressed: openStudyScreen,

                child: const Text(
                  'Study List',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}