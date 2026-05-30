
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedQuestionCount = 10;

  bool russianToEnglish = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Russian Vocabulary Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              children: [10, 20, 50, 100].map((count) {
                return ChoiceChip(
                  label: Text('$count'),
                  selected: selectedQuestionCount == count,
                  onSelected: (_) {
                    setState(() {
                      selectedQuestionCount = count;
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
              title: const Text('Russian → English'),
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
              title: const Text('English → Russian'),
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
                onPressed: () {
                  debugPrint(
                    'Start Quiz: '
                    '$selectedQuestionCount questions / '
                    '${russianToEnglish ? "RU→EN" : "EN→RU"}',
                  );

                  // TODO:
                  // Navigator.push(...)
                  // QuizScreenへ接続
                },
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO:
                  // MissedScreenへ接続
                },
                child: const Text('Missed Words'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO:
                  // GuessedScreenへ接続
                },
                child: const Text('Guess List'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO:
                  // StudyScreenへ接続
                },
                child: const Text('Study List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}