enum QuizModeType {
  range,
  tags,
  missed,
  guessed,
}

class QuizMode {
  /// 出題モード
  final QuizModeType modeType;

  /// 範囲指定モード用
  final int? startId;
  final int? endId;

  /// tags指定モード用
  final List<String> tags;

  const QuizMode({
    required this.modeType,
    this.startId,
    this.endId,
    this.tags = const [],
  });

  /// 範囲指定モード
  factory QuizMode.range({
    required int startId,
    required int endId,
  }) {
    return QuizMode(
      modeType: QuizModeType.range,
      startId: startId,
      endId: endId,
    );
  }

  /// tags指定モード
  factory QuizMode.tags({
    required List<String> tags,
  }) {
    return QuizMode(
      modeType: QuizModeType.tags,
      tags: tags,
    );
  }

  /// Missedのみ
  factory QuizMode.missed() {
    return const QuizMode(
      modeType: QuizModeType.missed,
    );
  }

  /// Guessedのみ
  factory QuizMode.guessed() {
    return const QuizMode(
      modeType: QuizModeType.guessed,
    );
  }

  bool get isRange =>
      modeType == QuizModeType.range;

  bool get isTags =>
      modeType == QuizModeType.tags;

  bool get isMissed =>
      modeType == QuizModeType.missed;

  bool get isGuessed =>
      modeType == QuizModeType.guessed;

  @override
  String toString() {
    return '''
QuizMode(
modeType: $modeType,
startId: $startId,
endId: $endId,
tags: $tags
)
''';
  }
}