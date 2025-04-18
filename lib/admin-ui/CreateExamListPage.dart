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
  final TextEditingController _random_count = TextEditingController();

  Future<void> _showExamDialog({
    String? examId,
    Map<String, dynamic>? currentData,
  }) async {
    _titleController.text = currentData?['title'] ?? '';
    _durationController.text = currentData?['duration']?.toString() ?? '';
    _random_count.text = currentData?['count'] ?? '';
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              examId == null ? 'Imtihon yaratish' : 'Imtihonni tahrirlash',
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85, // kengroq qilish
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Imtihon nomi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _random_count,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nechta imtihon ajratib olishi kerakligi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Imtihon vaqti (daqiqada)',
                        border: OutlineInputBorder(),
                      ),
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
                  final title = _titleController.text.trim();
                  final duration = int.tryParse(
                    _durationController.text.trim(),
                  );
                  final count = _random_count.text.trim().toString();
                  if (title.isEmpty || duration == null || duration <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Iltimos, barcha maydonlarni to‘g‘ri to‘ldiring',
                        ),
                      ),
                    );
                    return;
                  }

                  if (examId == null) {
                    await _examService.createExam({
                      'title': title,
                      'duration': duration,
                      'count': count,
                    });
                  } else {
                    await _examService.editExam(examId, {
                      'title': title,
                      'duration': duration,
                      'count': count,
                    });
                  }

                  Navigator.pop(context);
                },
                child: const Text('Saqlash'),
              ),
            ],
          ),
    );
  }

  // Qo‘shimcha kerakli controller
  final TextEditingController _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,

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
              final duration = exam['duration']; // vaqtni ham chiqaramiz
              final count = exam['count'];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.quiz, color: Colors.blue.shade700),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Vaqti: $duration daqiqa , $count ta random savol',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    trailing: SizedBox(
                      width: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () async {
                              await _showExamDialog(
                                examId: exam.id,
                                currentData: {
                                  'title': title,
                                  'duration': duration,
                                  'count': count,
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _examService.deleteExam(exam.id);
                            },
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TestListPage(
                                examId: exam.id,
                                examTitle: title,
                              ),
                        ),
                      );
                    },
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
