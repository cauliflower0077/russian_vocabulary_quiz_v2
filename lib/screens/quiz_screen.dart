// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart';

import '../models/word.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../app_navigation.dart';
import '../widgets/answer_button.dart';

class QuizScreen extends StatefulWidget {
  final List<Word> words;

  final int questionCount;

  final bool russianToEnglish;

  const QuizScreen({
    super.key,
    required this.words,
    required this.questionCount,
    required this.russianToEnglish,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Word> quizWords;

  int currentIndex = 0;

  bool answered = false;

  bool isCorrect = false;

  late Word currentWord;

  late List<String> choices;

  String correctAnswer = '';

  int correctCount = 0;

  final List<Word> wrongWords = [];

  final List<Word> guessedWords = [];

  @override
  void initState() {
    super.initState();

    final shuffled = [...widget.words]..shuffle();

    final count =
        widget.questionCount.clamp(1, widget.words.length);
    quizWords = shuffled.take(count).toList();

    loadQuestion();
  }

  void loadQuestion() {
    currentWord = quizWords[currentIndex];

    correctAnswer = widget.russianToEnglish
        ? currentWord.en
        : currentWord.ru;

    final wrongChoices = widget.words
        .where((word) => word.id != currentWord.id)
        .toList()
      ..shuffle();

    final wrongAnswers = wrongChoices.take(3).map((word) {
      return widget.russianToEnglish ? word.en : word.ru;
    }).toList();

    choices = [
      correctAnswer,
      ...wrongAnswers,
    ]..shuffle();

    answered = false;
  }

  Future<void> checkAnswer(String selected) async {
    if (answered) return;

    final correct = selected == correctAnswer;

    if (!correct) {
      await StorageService.addMissedId(currentWord.id);
    }

    setState(() {
        answered = true;
        isCorrect = correct;

        if (correct) {
            correctCount++;
        } else {
            wrongWords.add(currentWord);
        }
    });
  }

  Future<void> nextQuestion() async {

    if (currentIndex >= quizWords.length - 1) {
        AppNavigation.replaceWithResult(
          context,
          correctCount: correctCount,
          totalQuestions: quizWords.length,
          wrongWords: wrongWords,
          guessedWords: guessedWords,
        );

        return;
}

    setState(() {
      currentIndex++;
    });

    loadQuestion();
  }

  Future<void> markGuessed() async {
    await StorageService.addGuessedId(currentWord.id);

    if (!guessedWords.contains(currentWord)) {
        guessedWords.add(currentWord);
        }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to Guess List'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayWord = widget.russianToEnglish
        ? currentWord.ru
        : currentWord.en;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${currentIndex + 1}/${quizWords.length}',
        ),
        actions: [
          IconButton(
            onPressed: markGuessed,
            icon: const Icon(Icons.star_border),
            tooltip: 'I guessed',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              displayWord,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: IconButton(
                onPressed: () async {
                  await TtsService.speak(currentWord.ruTts);
                },
                iconSize: 36,
                icon: const Icon(Icons.volume_up),
              ),
            ),

            const SizedBox(height: 24),

            ...choices.map((choice) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnswerButton(
                  text: choice,
                  disabled: answered,
                  onTap: () {
                    checkAnswer(choice);
                  },
                ),
              );
            }),

            const SizedBox(height: 24),

            if (answered)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      isCorrect
                          ? '⭕ Correct'
                          : '❌ Incorrect',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Correct Answer:\n$correctAnswer',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            if (answered)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text(
                    currentIndex >= quizWords.length - 1
                        ? 'Finish'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}