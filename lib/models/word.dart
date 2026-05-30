

class Word {
  final int id;
  final String ru;
  final String ruTts;
  final String en;
  final String category;
  final List<String> tags;

  Word({
    required this.id,
    required this.ru,
    required this.ruTts,
    required this.en,
    required this.category,
    required this.tags,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int,
      ru: json['ru'] as String,
      ruTts: json['ru_tts'] as String,
      en: json['en'] as String,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ru': ru,
      'ru_tts': ruTts,
      'en': en,
      'category': category,
      'tags': tags,
    };
  }
}

