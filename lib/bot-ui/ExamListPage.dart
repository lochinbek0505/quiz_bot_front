import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'CacheService.dart';
import 'QuizPage.dart';

class ExamListPage extends StatefulWidget {
  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedLanguage = 'Uzbek';

  Future<void> load() async {
    CacheService pref = CacheService();

    selectedLanguage = (await pref.getData("lan"))!;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: SizedBox(),
        title: Text(
          selectedLanguage == "Uzbek"
              ? "Imtihonlar"
              : selectedLanguage == "English"
              ? "Exams"
              : "Экзамены",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('exams').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(
              child: Text(
                selectedLanguage == "Uzbek"
                    ? "Imtihonlar topilmadi"
                    : selectedLanguage == "English"
                    ? "No exams found"
                    : "Экзамены не найдены",
              ),
            );

          final exams = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final title = exam['title'] ?? 'No Title';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.school, color: Colors.blue),
                  ),
                  subtitle: Text(
                    selectedLanguage == "Uzbek"
                        ? "Imtihon vaqti ${exam['duration']} minut"
                        : selectedLanguage == "English"
                        ? "Exam duration is ${exam['duration']} minutes"
                        : "Продолжительность экзамена ${exam['duration']} минут",
                  ),
                  title: Text(
                    title,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => QuizPage(examId: exam.id, examTitle: title),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
