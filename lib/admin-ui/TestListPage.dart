import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'ExamService.dart';

class TestListPage extends StatefulWidget {
  final String examId;
  final String examTitle;

  const TestListPage({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<TestListPage> createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  final ExamService _examService = ExamService();

  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int _correctIndex = 0;

  Future<void> _showTestDialog({
    String? testId,
    Map<String, dynamic>? currentData,
  }) async {
    if (currentData != null) {
      _questionController.text = currentData['question'];
      final List options = currentData['options'];
      for (int i = 0; i < 4; i++) {
        _optionControllers[i].text = options[i];
      }
      _correctIndex = currentData['correctAnswerIndex'];
    } else {
      _questionController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
      _correctIndex = 0;
    }

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              testId == null ? ' Test qo\'shish' : 'Testni tahrirlash',
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      labelText: 'Savol',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ...List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: TextField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Variant ${index + 1}',
                        ),
                      ),
                    );
                  }),
                  DropdownButtonFormField<int>(
                    value: _correctIndex,

                    items: List.generate(4, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('To\'gri javob: ${index + 1}'),
                      );
                    }),
                    onChanged: (val) => setState(() => _correctIndex = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final testData = {
                    'question': _questionController.text,
                    'options': _optionControllers.map((e) => e.text).toList(),
                    'correctAnswerIndex': _correctIndex,
                  };

                  if (testId == null) {
                    await _examService.addTest(widget.examId, testData);
                  } else {
                    await _examService.editTest(
                      widget.examId,
                      testId,
                      testData,
                    );
                  }

                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final testCollection = FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.examId)
        .collection('tests');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '"${widget.examTitle}"',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: testCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final tests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              final question = test['question'];

              return Padding(
                padding: EdgeInsets.all(10),
                child: Card(
                  elevation: 4,
                  color: Colors.white,
                  child: ListTile(
                    title: Text(question),
                    trailing: PopupMenuButton(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _showTestDialog(
                            testId: test.id,
                            currentData: test.data() as Map<String, dynamic>,
                          );
                        } else if (value == 'delete') {
                          await _examService.deleteTest(widget.examId, test.id);
                        }
                      },
                      itemBuilder:
                          (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Tahrirlash'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text("O'chirish"),
                            ),
                          ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTestDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
