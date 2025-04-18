import 'package:cloud_firestore/cloud_firestore.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadExams() async {
    final querySnapshot = await _firestore.collection('groups').get();

    List<Map<String, dynamic>> loadedExams = [];

    for (var doc in querySnapshot.docs) {
      loadedExams.add({
        'title': doc.id,
        'description': doc['description'] ?? 'No title',
      });
    }
  }

  /// Imtihon testlarini yuklash (va imtihonning umumiy ma'lumotlari)
  Future<Map<String, dynamic>> getExamWithTests(String examId) async {
    // 1. Imtihon ma'lumotlarini olish
    final examDoc = await _firestore.collection('exams').doc(examId).get();
    if (!examDoc.exists) {
      throw Exception("Imtihon topilmadi");
    }

    final examData = examDoc.data()!;
    final count = examData['count'] ?? "";
    final duration = examData['duration'] ?? 60; // daqiqalarda
    final difficulty = examData['difficulty'] ?? "o'rta";
    final examTitle = examData['title'] ?? "Noma'lum";

    // 2. Testlarni olish
    final testsSnapshot =
        await _firestore
            .collection('exams')
            .doc(examId)
            .collection('tests')
            .get();

    final tests =
        testsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

    // 3. Barcha ma’lumotlarni birga qaytarish
    return {
      'title': examTitle,
      'difficulty': difficulty,
      'duration': duration,
      'count': count,
      'tests': tests,
    };
  }

  /// Natijani saqlash
  Future<void> submitResult({
    required String examId,
    required String userId,
    required String username,
    required int correctAnswers,
    required int totalQuestions,
    required String group,
  }) async {
    final score = ((correctAnswers / totalQuestions) * 100).round();

    await _firestore
        .collection('exams')
        .doc(examId)
        .collection('users')
        .doc(userId)
        .set({
          'username': username,
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'score': score,
          'timestamp': FieldValue.serverTimestamp(),
        });

    await _firestore
        .collection('result')
        .doc(group)
        .collection('users')
        .doc(userId)
        .set({
          'username': username,
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'score': score,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  /// Reyting ro'yxatini olish
  Future<List<Map<String, dynamic>>> getRanking(String examId) async {
    final snapshot =
        await _firestore
            .collection('examId')
            .doc(examId)
            .collection('users')
            .orderBy('score', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['userId'] = doc.id;
      return data;
    }).toList();
  }
}
