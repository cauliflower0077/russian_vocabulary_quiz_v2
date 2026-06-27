import 'package:flutter/material.dart';

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
    // v0.3 次フェーズで実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'StudyScreen connection will be added later.',
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