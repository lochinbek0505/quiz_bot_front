import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_bot/admin-ui/CreateExamListPage.dart';

import 'bot-ui/ExamListPage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // go_router instansiyasini yaratish
    final GoRouter _router = GoRouter(
      initialLocation: '/',
      routes: [
        // Home sahifasi
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return ExamListPage();
          },
          routes: [
            // About sahifasi
            GoRoute(
              path: '/admin',
              builder: (BuildContext context, GoRouterState state) {
                return CreateExamListPage();
              },
            ),
            // Profile sahifasi
          ],
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blueAccent,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}
