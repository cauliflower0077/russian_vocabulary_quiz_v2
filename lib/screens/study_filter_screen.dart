import 'package:flutter/material.dart';

import '../models/study_filter.dart';
import 'study_screen.dart';

class StudyFilterScreen extends StatefulWidget {
  const StudyFilterScreen({super.key});

  @override
  State<StudyFilterScreen> createState() =>
      _StudyFilterScreenState();
}

class _StudyFilterScreenState
    extends State<StudyFilterScreen> {
  int selectedMode = 0;

  final TextEditingController startIdController =
      TextEditingController(text: '1');

  final TextEditingController endIdController =
      TextEditingController(text: '100');

  final TextEditingController tagsController =
      TextEditingController();

  @override
  void dispose() {
    startIdController.dispose();
    endIdController.dispose();
    tagsController.dispose();

    super.dispose();
  }

  void openStudyList() {
    late StudyFilter filter;

    switch (selectedMode) {
      case 0:
        filter = StudyFilter.all();
        break;

      case 1:
        filter = StudyFilter.range(
          startId:
              int.tryParse(startIdController.text) ??
                  1,
          endId:
              int.tryParse(endIdController.text) ??
                  100,
        );
        break;

      case 2:
        final tags = tagsController.text
            .split(RegExp(r'\s+'))
            .where((e) => e.trim().isNotEmpty)
            .toList();

        filter = StudyFilter.tags(
          tags: tags,
        );
        break;

      default:
        filter = StudyFilter.all();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudyScreen(
          filter: filter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Filter',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile<int>(
              title: const Text('All Words'),
              value: 0,
              groupValue: selectedMode,
              onChanged: (value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),

            RadioListTile<int>(
              title: const Text('Range Mode'),
              value: 1,
              groupValue: selectedMode,
              onChanged: (value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),

            if (selectedMode == 1)
              Column(
                children: [
                  TextField(
                    controller:
                        startIdController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText: 'Start ID',
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                        endIdController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText: 'End ID',
                    ),
                  ),
                ],
              ),

            RadioListTile<int>(
              title: const Text('Tags Mode'),
              value: 2,
              groupValue: selectedMode,
              onChanged: (value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),

            if (selectedMode == 2)
              TextField(
                controller: tagsController,
                decoration:
                    const InputDecoration(
                  labelText:
                      '#A1 #動詞 #IT',
                  hintText:
                      '#A1 #コロケーション',
                ),
              ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: openStudyList,
                child: const Text(
                  'Open Study List',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}