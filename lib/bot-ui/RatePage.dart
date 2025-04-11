import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingPage extends StatelessWidget {
  final List<Map<String, dynamic>> users = [
    {"name": "Lochinbek", "score": 98},
    {"name": "Ali", "score": 95},
    {"name": "Vali", "score": 91},
    {"name": "Sami", "score": 87},
    {"name": "Nodir", "score": 82},
    {"name": "Doston", "score": 79},
    {"name": "Aziz", "score": 75},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // dark blue-gray
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            if (index < 3) {
              // Top 3 design
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      index == 0
                          ? Colors.amberAccent
                          : index == 1
                          ? Colors.grey.shade400
                          : Colors.brown.shade300,
                      Colors.black12,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
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
                      style: TextStyle(
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
                      color: Colors.white,
                    ),
                  ),
                  trailing: Text(
                    "${user['score']}%",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            } else {
              // Others
              return Card(
                color: Colors.white.withOpacity(0.05),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    user['name'],
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  trailing: Text(
                    "${user['score']}%",
                    style: GoogleFonts.poppins(color: Colors.white70),
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
