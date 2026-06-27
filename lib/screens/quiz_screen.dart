// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart';

import '../app_navigation.dart';
import '../models/quiz_mode.dart';
import '../models/word.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../widgets/answer_button.dart';

class QuizScreen extends StatefulWidget {
  final List<Word> words;
  final int questionCount;
  final bool russianToEnglish;
  final QuizMode quizMode;

  const QuizScreen({
    super.key,
    required this.words,
    required this.questionCount,
    required this.russianToEnglish,
    required this.quizMode,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Word> quizWords = [];

  int currentIndex = 0;

  bool isLoading = true;
  bool answered = false;
  bool isCorrect = false;

  late Word currentWord;

  late List<String> choices;
  final Map<String, Word> choiceWordMap = {};

  String correctAnswer = '';
  String? selectedAnswer;

  int correctCount = 0;

  final List<Word> wrongWords = [];
  final List<Word> guessedWords = [];

  @override
  void initState() {
    super.initState();
    prepareQuiz();
  }

  Future<void> prepareQuiz() async {
    List<Word> sourceWords = [...widget.words];

    if (widget.quizMode.isRange) {
      sourceWords = sourceWords.where((word) {
        return word.id >= widget.quizMode.startId! &&
            word.id <= widget.quizMode.endId!;
      }).toList();
    }

    if (widget.quizMode.isTags) {
      sourceWords = sourceWords.where((word) {
        return widget.quizMode.tags.every(
          (tag) => word.tags.contains(tag),
        );
      }).toList();
    }

    if (widget.quizMode.isMissed) {
      final missedIds = await StorageService.getMissedIds();
      sourceWords = sourceWords.where((word) {
        return missedIds.contains(word.id);
      }).toList();
    }

    if (widget.quizMode.isGuessed) {
      final guessedIds = await StorageService.getGuessedIds();
      sourceWords = sourceWords.where((word) {
        return guessedIds.contains(word.id);
      }).toList();
    }

    sourceWords.shuffle();

    final count = widget.questionCount.clamp(
      1,
      sourceWords.length,
    );

    quizWords = sourceWords.take(count).toList();

    if (!mounted) return;

    if (quizWords.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    loadQuestion();

    setState(() {
      isLoading = false;
    });
  }

  String answerTextOf(Word word) {
    return widget.russianToEnglish ? word.en : word.ru;
  }

  String oppositeTextOf(Word word) {
    return widget.russianToEnglish ? word.ru : word.en;
  }

  void loadQuestion() {
    currentWord = quizWords[currentIndex];

    correctAnswer = answerTextOf(currentWord);

    choiceWordMap.clear();
    choiceWordMap[correctAnswer] = currentWord;

    final wrongChoices = widget.words
        .where((word) => word.id != currentWord.id)
        .toList()
      ..shuffle();

    final wrongAnswers = wrongChoices.take(3).map((word) {
      final answer = answerTextOf(word);
      choiceWordMap[answer] = word;
      return answer;
    }).toList();

    choices = [
      correctAnswer,
      ...wrongAnswers,
    ]..shuffle();

    answered = false;
    isCorrect = false;
    selectedAnswer = null;
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
      selectedAnswer = selected;

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

    setState(() {});
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

  Widget buildAnswerDetail() {
    final selected = selectedAnswer;
    final selectedWord =
        selected == null ? null : choiceWordMap[selected];

    final correctWord = currentWord;

    if (isCorrect) {
      return Text(
        'Correct Answer:\n$correctAnswer',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      );
    }

    return Column(
      children: [
        Text(
          'Your Answer:\n${selected ?? ''}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),

        if (selectedWord != null) ...[
          const SizedBox(height: 8),
          Text(
            '${answerTextOf(selectedWord)}\n=\n${oppositeTextOf(selectedWord)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],

        const SizedBox(height: 16),

        Text(
          'Correct Answer:\n$correctAnswer',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),

        const SizedBox(height: 8),

        Text(
          '${answerTextOf(correctWord)}\n=\n${oppositeTextOf(correctWord)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (quizWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(
          child: Text('No matching words found.'),
        ),
      );
    }

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
                      isCorrect ? 'Correct' : 'Incorrect',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    buildAnswerDetail(),
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
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}