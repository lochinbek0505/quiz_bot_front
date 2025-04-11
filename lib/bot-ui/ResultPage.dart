import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_bot/bot-ui/RatePage.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final String examId;

  const ResultPage({Key? key, required this.score, required this.examId})
    : super(key: key);

  String getResultText() {
    if (score >= 90) return "🔥 Ajoyib natija!";
    if (score >= 75) return "✅ Yaxshi ish!";
    if (score >= 50) return "💪 Harakat qilish kerak";
    return "😥 Ko‘proq mashq qil";
  }

  Color getColor() {
    if (score >= 90) return Colors.greenAccent;
    if (score >= 75) return Colors.blueAccent;
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = getColor();
    final resultText = getResultText();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 100, color: textColor),
              const SizedBox(height: 20),
              Text(
                "Natijangiz:",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "$score%",
                style: GoogleFonts.poppins(
                  fontSize: 64,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                resultText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 22, color: textColor),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => RatingPage(examId: examId),
                    ),
                  );
                },
                icon: const Icon(Icons.star_rate),
                label: Text(
                  "Reyting",
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
