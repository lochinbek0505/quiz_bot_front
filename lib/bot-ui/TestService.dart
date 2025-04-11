import 'package:cloud_firestore/cloud_firestore.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTests(String examId) async {
    final snapshot =
        await _firestore
            .collection('exams')
            .doc(examId)
            .collection('tests')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> submitResult({
    required String examId,
    required String userId,
    required String username,
    required int correctAnswers,
    required int totalQuestions,
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
        });
  }

  Future<List<Map<String, dynamic>>> getRanking(String examId) async {
    final snapshot =
        await _firestore
            .collection('results')
            .doc(examId)
            .collection('users')
            .get();

    final results =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['userId'] = doc.id;
          return data;
        }).toList();

    results.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return results;
  }
}
