// lib/screens/study_screen.dart

import 'package:flutter/material.dart';

import '../models/study_filter.dart';
import '../models/word.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

enum SortType {
  id,
  russian,
  english,
  random,
}

class StudyScreen extends StatefulWidget {
  final StudyFilter filter;

  const StudyScreen({
    super.key,
    required this.filter,
  });

  @override
  State<StudyScreen> createState() =>
      _StudyScreenState();
}

class _StudyScreenState
    extends State<StudyScreen> {
  final TextEditingController searchController =
      TextEditingController();

  List<Word> allWords = [];

  List<Word> filteredWords = [];

  SortType sortType = SortType.id;

  bool russianToEnglish = true;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadWords();
  }

  Future<void> loadWords() async {
    final words =
        await WordService.loadWords();

    if (!mounted) return;

    List<Word> filtered = [...words];

    if (widget.filter.isRange) {
      filtered = filtered.where((word) {
        return word.id >=
                widget.filter.startId! &&
            word.id <=
                widget.filter.endId!;
      }).toList();
    }

    if (widget.filter.isTags) {
      filtered = filtered.where((word) {
        return widget.filter.tags.every(
          (tag) => word.tags.contains(tag),
        );
      }).toList();
    }

    setState(() {
      allWords = filtered;
      filteredWords = [...filtered];
      isLoading = false;
    });

    applyFilter();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  void applyFilter() {
    final query =
        searchController.text
            .trim()
            .toLowerCase();

    List<Word> result = [...allWords];

    if (query.isNotEmpty) {
      final tokens = query.split(' ');

      result = result.where((word) {
        final ru = word.ru.toLowerCase();

        final en = word.en.toLowerCase();

        final tags = word.tags
            .map((tag) => tag.toLowerCase())
            .toList();

        return tokens.every((token) {
          return ru.contains(token) ||
              en.contains(token) ||
              tags.any(
                (tag) => tag.contains(token),
              );
        });
      }).toList();
    }

    switch (sortType) {
      case SortType.id:
        result.sort(
          (a, b) =>
              a.id.compareTo(b.id),
        );
        break;

      case SortType.russian:
        result.sort(
          (a, b) =>
              a.ru.compareTo(b.ru),
        );
        break;

      case SortType.english:
        result.sort(
          (a, b) =>
              a.en.compareTo(b.en),
        );
        break;

      case SortType.random:
        result.shuffle();
        break;
    }

    setState(() {
      filteredWords = result;
    });
  }

  Widget buildSortButton({
    required String text,
    required SortType type,
  }) {
    final selected = sortType == type;

    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) {
        setState(() {
          sortType = type;
        });

        applyFilter();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study List'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                russianToEnglish =
                    !russianToEnglish;
              });
            },
            icon: const Icon(
              Icons.swap_horiz,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller:
                            searchController,
                        decoration:
                            const InputDecoration(
                          hintText:
                              'Search words or tags',
                          prefixIcon:
                              Icon(Icons.search),
                          border:
                              OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          applyFilter();
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          buildSortButton(
                            text: 'ID',
                            type: SortType.id,
                          ),
                          buildSortButton(
                            text: 'Russian',
                            type:
                                SortType.russian,
                          ),
                          buildSortButton(
                            text: 'English',
                            type:
                                SortType.english,
                          ),
                          buildSortButton(
                            text: 'Random',
                            type:
                                SortType.random,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount:
                        filteredWords.length,
                    itemBuilder:
                        (context, index) {
                      final word =
                          filteredWords[index];

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  russianToEnglish
                                      ? word.ru
                                      : word.en,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 16,
                              ),

                              Expanded(
                                child: Text(
                                  russianToEnglish
                                      ? word.en
                                      : word.ru,
                                  textAlign:
                                      TextAlign
                                          .right,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const SizedBox(
                                height: 8,
                              ),

                              Text(
                                word.ruTts,
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                word.tags.join(
                                  ' ',
                                ),
                              ),
                            ],
                          ),

                          trailing: IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                            ),
                            onPressed: () async {
                              await TtsService
                                  .speak(
                                word.ruTts,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}