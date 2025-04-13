import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectRatingPage extends StatefulWidget {
  @override
  State<SelectRatingPage> createState() => _SelectRatingPageState();
}

class _SelectRatingPageState extends State<SelectRatingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> exams = [];

  String? selectedExamId;

  @override
  void initState() {
    super.initState();
    loadExams();
  }

  Future<void> loadExams() async {
    final querySnapshot = await _firestore.collection('exams').get();

    List<Map<String, dynamic>> loadedExams = [];

    for (var doc in querySnapshot.docs) {
      loadedExams.add({'id': doc.id, 'title': doc['title'] ?? 'No title'});
    }

    setState(() {
      exams = loadedExams;
    });
  }

  Future<void> loadRanking(String examId) async {
    final querySnapshot =
        await _firestore
            .collection('exams')
            .doc(examId)
            .collection('users')
            .orderBy('score', descending: true)
            .get();

    List<Map<String, dynamic>> loadedUsers = [];

    for (var doc in querySnapshot.docs) {
      loadedUsers.add({'name': doc['username'], 'score': doc['score']});
    }

    setState(() {
      users = loadedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        leading: SizedBox(),
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          "🏆 Reyting",
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedExamId,
              items:
                  exams.map((exam) {
                    return DropdownMenuItem<String>(
                      value: exam['id'],
                      child: Text(
                        exam['title'],
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedExamId = value;
                  users = [];
                });
                if (value != null) {
                  loadRanking(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  users.isEmpty
                      ? selectedExamId == null
                          ? const Center(
                            child: Text(
                              "Imtihon tanlanmagan",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                          : const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];

                          if (index < 3) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    index == 0
                                        ? Colors.orangeAccent
                                        : index == 1
                                        ? Colors.deepPurple.shade200
                                        : Colors.greenAccent.shade100,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                trailing: Text(
                                  "${user['score']}%",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Card(
                              color: Colors.grey.shade100,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.shade100
                                      .withOpacity(0.5),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                title: Text(
                                  user['name'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                trailing: Text(
                                  "${user['score']}%",
                                  style: GoogleFonts.poppins(
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
