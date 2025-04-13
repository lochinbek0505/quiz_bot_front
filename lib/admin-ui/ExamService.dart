import 'package:cloud_firestore/cloud_firestore.dart';

class ExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create an exam
  Future<String> createExam(Map<String, dynamic> map) async {
    final docRef = await _firestore.collection('exams').add(map);
    return docRef.id;
  }

  // Edit an existing exam
  Future<void> editExam(String examId, Map<String, dynamic> map) async {
    await _firestore.collection('exams').doc(examId).update(map);
  }

  // Delete an exam and its associated tests and results
  Future<void> deleteExam(String examId) async {
    final testCollection = _firestore
        .collection('exams')
        .doc(examId)
        .collection('tests');
    final tests = await testCollection.get();

    // Delete all tests related to this exam
    for (final doc in tests.docs) {
      await doc.reference.delete();
    }

    // Delete the exam and its results
    await _firestore.collection('exams').doc(examId).delete();
    await _firestore.collection('results').doc(examId).delete();
  }

  // Add a test to an exam
  Future<String> addTest(String examId, Map<String, dynamic> testData) async {
    final testRef = await _firestore
        .collection('exams')
        .doc(examId)
        .collection('tests')
        .add(testData);
    return testRef.id;
  }

  // Edit an existing test
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

  // Delete a test from an exam
  Future<void> deleteTest(String examId, String testId) async {
    await _firestore
        .collection('exams')
        .doc(examId)
        .collection('tests')
        .doc(testId)
        .delete();
  }

  // Create a group for an exam
  Future<String> createGroup(Map<String, dynamic> groupData) async {
    final groupRef = await _firestore.collection('groups').add(groupData);
    return groupRef.id;
  }

  // Edit an existing group within an exam
  Future<void> editGroup(
    String groupId,
    Map<String, dynamic> updatedData,
  ) async {
    await _firestore.collection('groups').doc(groupId).update(updatedData);
  }

  // Delete a group from an exam
  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }

  // Get all groups for an exam
  Future<List<Map<String, dynamic>>> getGroups() async {
    final groupSnapshot = await _firestore.collection('groups').get();

    return groupSnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  // Get a single group by its ID
  Future<Map<String, dynamic>?> getGroup(String groupId) async {
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();

    return groupDoc.exists ? groupDoc.data() as Map<String, dynamic> : null;
  }
}
