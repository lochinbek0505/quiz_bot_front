import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_bot/admin-ui/MainAdminPage.dart';
import 'package:quiz_bot/bot-ui/MainPage.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  final tgWebAppData = Uri.base.queryParameters['tgWebAppData'];
  if (tgWebAppData != null) {
    final decoded = utf8.decode(base64.decode(tgWebAppData));
    print('Telegram user data: $decoded');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tg = TelegramWebApp.instance; // Telegram API instance
    final router = GoRouter(
      initialLocation: '/admin',
      redirect: (context, state) {
        final uri = state.uri;

        // Telegram WebApp query borligini tekshiramiz
        if (uri.queryParameters.containsKey('tgWebAppData')) {
          // Query'ni olib tashlab, faqat path'ga yo‘naltiramiz
          return uri.path;
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => Mainpage()),
        GoRoute(path: '/admin', builder: (context, state) => MainAdminPage()),
      ],
      errorPageBuilder:
          (context, state) => MaterialPage(
            child: MainAdminPage(), // fallback page
          ),
    );
    return MaterialApp.router(
      title: 'Imtihon bot',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
