import 'package:flutter/material.dart';
import 'package:quiz_bot/bot-ui/ExamListPage.dart';
import 'package:quiz_bot/bot-ui/SelectRating.dart';
import 'package:quiz_bot/bot-ui/SettingsPage.dart';

import 'CacheService.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int selecatedIndex = 0;
  var pages = [ExamListPage(), SelectRatingPage(), Settingspage()];

  Future<String?> showNameDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Iltimos ismingizni kiriting"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Ismingizni kiriting",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Bekor qilish"),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                CacheService pref = CacheService();
                pref.saveData("name", name);
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Iltimos ismingizni kiriting."),
                    ),
                  );
                }
              },
              child: const Text("Kiritish"),
            ),
          ],
        );
      },
    );
  }

  var username = "";
  var lan = "";

  Future<void> load() async {
    CacheService pref = CacheService();

    username = (await pref.getData("name"))!;
    if (username.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final name = await showNameDialog(context);
        if (name != null && mounted) {
          setState(() {
            username = name;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/home.png", width: 25, height: 25),
            label: "",
          ),

          BottomNavigationBarItem(
            icon: Image.asset("assets/cup.png", width: 25, height: 25),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/setting.png", width: 25, height: 25),
            label: "",
          ),
        ],
        currentIndex: selecatedIndex,
        onTap: (index) {
          setState(() {
            selecatedIndex = index;
          });
        },
      ),
      body: pages[selecatedIndex],
    );
  }
}
