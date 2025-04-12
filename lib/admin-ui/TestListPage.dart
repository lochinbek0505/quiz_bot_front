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
  final TextEditingController _writtenAnswerController =
      TextEditingController();

  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int _correctIndex = 0;

  // Yangi controller va o'zgaruvchilar kerak
  final _levelOptions = ['Oson', 'O‘rta', 'Qiyin'];
  String _selectedLevel = 'Oson';
  bool _isWritten = false;

  Future<void> _showTestDialog({
    String? testId,
    Map<String, dynamic>? currentData,
  }) async {
    if (currentData != null) {
      _questionController.text = currentData['question'];
      _selectedLevel = currentData['level'] ?? 'Oson';
      _isWritten = currentData['isWritten'] ?? false;

      if (_isWritten) {
        _writtenAnswerController.text = currentData['writtenAnswer'] ?? '';
      } else {
        final List options = currentData['options'];
        for (int i = 0; i < 4; i++) {
          _optionControllers[i].text = options[i];
        }
        _correctIndex = currentData['correctAnswerIndex'];
      }
    } else {
      _questionController.clear();
      _writtenAnswerController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
      _correctIndex = 0;
      _selectedLevel = 'Oson';
      _isWritten = false;
    }

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  testId == null ? 'Test qo\'shish' : 'Testni tahrirlash',
                ),
                content: SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.85, // kengroq qilish
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        TextField(
                          controller: _questionController,
                          decoration: const InputDecoration(
                            labelText: 'Savol',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Checkbox(
                              value: _isWritten,
                              onChanged:
                                  (val) => setState(() => _isWritten = val!),
                            ),
                            const Text('Yozma savolmi?'),
                          ],
                        ),

                        const SizedBox(height: 15),

                        _isWritten
                            ? TextField(
                              controller: _writtenAnswerController,
                              decoration: const InputDecoration(
                                labelText:
                                    'To\'g\'ri javob (matn ko‘rinishida)',
                                border: OutlineInputBorder(),
                              ),
                            )
                            : Column(
                              children: [
                                ...List.generate(4, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: TextField(
                                      controller: _optionControllers[index],
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'Variant ${index + 1}',
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<int>(
                                  value: _correctIndex,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'To\'g\'ri variantni tanlang',
                                  ),
                                  items: List.generate(4, (index) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                        'To\'g\'ri javob: ${index + 1}',
                                      ),
                                    );
                                  }),
                                  onChanged:
                                      (val) =>
                                          setState(() => _correctIndex = val!),
                                ),
                              ],
                            ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedLevel,
                          decoration: const InputDecoration(
                            labelText: 'Murakkablik darajasi',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _levelOptions.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                );
                              }).toList(),
                          onChanged:
                              (val) => setState(() => _selectedLevel = val!),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Bekor qilish'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final testData = {
                        'question': _questionController.text,
                        'level': _selectedLevel,
                        'isWritten': _isWritten,
                      };

                      if (_isWritten) {
                        testData['writtenAnswer'] =
                            _writtenAnswerController.text;
                      } else {
                        testData['options'] =
                            _optionControllers.map((e) => e.text).toList();
                        testData['correctAnswerIndex'] = _correctIndex;
                      }

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
                    child: const Text('Saqlash'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Kerakli controller

  @override
  Widget build(BuildContext context) {
    final testCollection = FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.examId)
        .collection('tests');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examTitle, style: TextStyle(color: Colors.white)),
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
                    trailing: Container(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await _showTestDialog(
                                testId: test.id,
                                currentData:
                                    test.data() as Map<String, dynamic>,
                              );
                            },
                            icon: Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _examService.deleteTest(
                                widget.examId,
                                test.id,
                              );
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    //       trailing: PopupMenuButton(
                    //         onSelected: (value) async {
                    //           if (value == 'edit') {
                    //             await _showTestDialog(
                    //               testId: test.id,
                    //               currentData: test.data() as Map<String, dynamic>,
                    //             );
                    //           } else if (value == 'delete') {
                    //             await _examService.deleteTest(widget.examId, test.id);
                    //           }
                    //         },
                    //         itemBuilder:
                    //             (_) => [
                    //               const PopupMenuItem(
                    //                 value: 'edit',
                    //                 child: Text('Tahrirlash'),
                    //               ),
                    //               const PopupMenuItem(
                    //                 value: 'delete',
                    //                 child: Text("O'chirish"),
                    //               ),
                    //             ],
                    //       ),
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
