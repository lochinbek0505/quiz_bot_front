import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> languages = {
    'Uzbek': '🇺🇿 Uzbek',
    'English': '🇺🇸 English',
    'Russian': '🇷🇺 Russian',
  };
  String selectedLanguage = 'Uzbek';

  Future<String?> showNameDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    String? selectedGroup;

    // Fetch the list of groups from Firestore
    final querySnapshot = await _firestore.collection('groups').get();

    List<String> groups = [];
    for (var doc in querySnapshot.docs) {
      groups.add(doc['title']); // Adding group IDs to the list
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              selectedLanguage == "Uzbek"
                  ? Text("Iltimos ismingizni kiriting")
                  : selectedLanguage == "English"
                  ? Text("Please enter your name")
                  : Text("Пожалуйста, введите свое имя"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      selectedLanguage == "Uzbek"
                          ? "Ismingizni kiriting"
                          : selectedLanguage == "English"
                          ? "Enter your name"
                          : "Введите свое имя",
                ),
              ),
              const SizedBox(height: 20),
              if (groups.isNotEmpty)
                DropdownButton<String>(
                  hint: Text(
                    selectedLanguage == "Uzbek"
                        ? "Guruhni tanlang"
                        : selectedLanguage == "English"
                        ? "Select a group"
                        : "Выберите группу",
                  ),
                  value: selectedGroup,
                  isExpanded: true,
                  items:
                      groups.map<DropdownMenuItem<String>>((String group) {
                        return DropdownMenuItem<String>(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                  onChanged: (String? newGroup) {
                    setState(() {
                      selectedGroup = newGroup;
                      CacheService pref = new CacheService();
                      pref.saveData("group", selectedGroup!);
                    });
                  },
                ),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                items:
                    languages.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value!;
                    CacheService pref = CacheService();
                    pref.saveData("lan", selectedLanguage);
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                selectedLanguage == "Uzbek"
                    ? "Bekor qilish"
                    : selectedLanguage == "English"
                    ? "Cancel"
                    : "Отмена",
              ),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                CacheService pref = CacheService();
                pref.saveData("name", name);

                if (name.isNotEmpty && selectedGroup != null) {
                  // Proceed with both name and selected group
                  Navigator.of(context).pop('$name, $selectedGroup');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedLanguage == "Uzbek"
                            ? "Iltimos ismingizni va guruhni kiriting."
                            : selectedLanguage == "English"
                            ? "Please enter your name and group."
                            : "Пожалуйста, введите свое имя и группу.",
                      ),
                    ),
                  );
                }
              },
              child: Text(
                selectedLanguage == "Uzbek"
                    ? "Kiritish"
                    : selectedLanguage == "English"
                    ? "Submit"
                    : "Ввод",
              ),
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
    var guruh = "";
    var lan = "";
    // Get the username from CacheService
    try {
      username = await pref.getData("name") ?? "";
      guruh = await pref.getData("group") ?? "";
      lan = await pref.getData("lan") ?? "";
    } catch (e) {}
    print(" username = $username");

    // If username is empty, show the dialog to get the username
    if (username.isEmpty || guruh.isEmpty || lan.isEmpty) {
      await showNameDialog(context);
    } else {}
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
