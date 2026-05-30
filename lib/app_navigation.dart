import 'package:flutter/material.dart';

import 'models/word.dart';
import 'screens/guessed_screen.dart';
import 'screens/missed_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/study_screen.dart';

/// Local-only navigation (no named routes / no external APIs).
///
/// Stack conventions:
/// - [HomeScreen] is always `MaterialApp.home` (first route).
/// - Quiz: `Home` --push--> `Quiz`
/// - Result: `Home` --push--> `Quiz` --pushReplacement--> `Result`  =>  [Home, Result]
/// - Back from Result: `pop()` once => `Home`
/// - Study / Missed / Guessed: `Home` --push--> screen --pop--> `Home`
class AppNavigation {
  AppNavigation._();

  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(builder: (_) => screen),
    );
  }

  static Future<void> pushQuiz(
    BuildContext context, {
    required List<Word> words,
    required int questionCount,
    required bool russianToEnglish,
  }) {
    final safeCount = questionCount.clamp(1, words.length);

    return push<void>(
      context,
      QuizScreen(
        words: words,
        questionCount: safeCount,
        russianToEnglish: russianToEnglish,
      ),
    );
  }

  static Future<void> pushStudy(BuildContext context) {
    return push<void>(context, const StudyScreen());
  }

  static Future<void> pushMissed(BuildContext context) {
    return push<void>(context, const MissedScreen());
  }

  static Future<void> pushGuessed(BuildContext context) {
    return push<void>(context, const GuessedScreen());
  }

  static void replaceWithResult(
    BuildContext context, {
    required int correctCount,
    required int totalQuestions,
    required List<Word> wrongWords,
    required List<Word> guessedWords,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          correctCount: correctCount,
          totalQuestions: totalQuestions,
          wrongWords: wrongWords,
          guessedWords: guessedWords,
        ),
      ),
    );
  }

  /// Pops [ResultScreen] back to [HomeScreen] when stack is [Home, Result].
  static void popToHome(BuildContext context) {
    Navigator.of(context).pop();
  }
}
