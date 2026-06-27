enum StudyFilterType {
  all,
  range,
  tags,
}

class StudyFilter {
  final StudyFilterType type;

  final int? startId;
  final int? endId;

  final List<String> tags;

  const StudyFilter({
    required this.type,
    this.startId,
    this.endId,
    this.tags = const [],
  });

  factory StudyFilter.all() {
    return const StudyFilter(
      type: StudyFilterType.all,
    );
  }

  factory StudyFilter.range({
    required int startId,
    required int endId,
  }) {
    return StudyFilter(
      type: StudyFilterType.range,
      startId: startId,
      endId: endId,
    );
  }

  factory StudyFilter.tags({
    required List<String> tags,
  }) {
    return StudyFilter(
      type: StudyFilterType.tags,
      tags: tags,
    );
  }

  bool get isAll =>
      type == StudyFilterType.all;

  bool get isRange =>
      type == StudyFilterType.range;

  bool get isTags =>
      type == StudyFilterType.tags;
}