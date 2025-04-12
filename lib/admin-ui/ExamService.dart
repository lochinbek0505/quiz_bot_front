import 'package:cloud_firestore/cloud_firestore.dart';

class ExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createExam(Map<String, dynamic> map) async {
    final docRef = await _firestore.collection('exams').add(map);
    return docRef.id;
  }

  Future<void> editExam(String examId, Map<String, dynamic> map) async {
    await _firestore.collection('exams').doc(examId).update(map);
  }

  Future<void> deleteExam(String examId) async {
    final testCollection = _firestore
        .collection('exams')
        .doc(examId)
        .collection('tests');
    final tests = await testCollection.get();

    for (final doc in tests.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('exams').doc(examId).delete();
    await _firestore.collection('results').doc(examId).delete();
  }

  Future<String> addTest(String examId, Map<String, dynamic> testData) async {
    final testRef = await _firestore
        .collection('exams')
        .doc(examId)
        .collection('tests')
        .add(testData);
    return testRef.id;
  }

  Future<void> editTest(
    String examId,
    String testId,
    Map<String, dynamic> updatedData,
  ) async {
    await _firestore
        .collection('exams')
        .doc(examId)
        .collection('tests')
        .doc(testId)
        .update(updatedData);
  }

  Future<void> deleteTest(String examId, String testId) async {
    await _firestore
        .collection('exams')
        .doc(examId)
        .collection('tests')
        .doc(testId)
        .delete();
  }
}
