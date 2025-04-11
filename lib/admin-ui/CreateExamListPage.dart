import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'ExamService.dart';
import 'TestListPage.dart';

class CreateExamListPage extends StatefulWidget {
  const CreateExamListPage({super.key});

  @override
  State<CreateExamListPage> createState() => _CreateExamListPageState();
}

class _CreateExamListPageState extends State<CreateExamListPage> {
  final ExamService _examService = ExamService();
  final TextEditingController _titleController = TextEditingController();

  Future<void> _showExamDialog({String? examId, String? currentTitle}) async {
    _titleController.text = currentTitle ?? '';

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              examId == null ? 'Imtihon yaratish' : 'Imtihonni tahrirlash',
            ),
            content: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Imtihon nomi',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (examId == null) {
                    await _examService.createExam(_titleController.text);
                  } else {
                    await _examService.editExam(examId, _titleController.text);
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
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Imtihonlar', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('exams').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final exams = snapshot.data!.docs;

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final title = exam['title'];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(Icons.question_mark_sharp),
                    title: Text(title),
                    trailing: PopupMenuButton(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _showExamDialog(
                            examId: exam.id,
                            currentTitle: title,
                          );
                        } else if (value == 'delete') {
                          await _examService.deleteExam(exam.id);
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
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => TestListPage(
                                  examId: exam.id,
                                  examTitle: title,
                                ),
                          ),
                        ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExamDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
