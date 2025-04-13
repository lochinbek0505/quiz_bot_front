import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingPage extends StatefulWidget {
  final String examId;

  RatingPage({required this.examId});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    loadRanking();
  }

  Future<void> loadRanking() async {
    final querySnapshot =
        await _firestore
            .collection('exams')
            .doc(widget.examId)
            .collection('users')
            .orderBy('score', descending: true) // Saralash score bo'yicha
            .get();

    List<Map<String, dynamic>> loadedUsers = [];

    querySnapshot.docs.forEach((doc) {
      loadedUsers.add({'name': doc['username'], 'score': doc['score']});
    });

    setState(() {
      users = loadedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFEDF2F7,
      ), // light gray background for daytime
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).push("/");
          },
          icon: Icon(Icons.home, color: Colors.white),
        ),
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
        child:
            users.isEmpty
                ? Center(child: CircularProgressIndicator())
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
                            backgroundColor: Colors.orange.shade100.withOpacity(
                              0.5,
                            ),
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
                            style: GoogleFonts.poppins(color: Colors.teal),
                          ),
                        ),
                      );
                    }
                  },
                ),
      ),
    );
  }
}
