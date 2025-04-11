import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bot-ui/HomePage.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blueAccent,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: HomePage(),
    );
  }
}
