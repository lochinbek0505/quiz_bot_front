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
          title: const Text("Iltimos ismingizni kiriting"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Ismingizni kiriting",
                ),
              ),
              const SizedBox(height: 20),
              if (groups.isNotEmpty)
                DropdownButton<String>(
                  hint: const Text("Guruhni tanlang"),
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
            ],
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

                if (name.isNotEmpty && selectedGroup != null) {
                  // Proceed with both name and selected group
                  Navigator.of(context).pop('$name, $selectedGroup');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Iltimos ismingizni va guruhni kiriting."),
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

    // Get the username from CacheService
    try {
      username = await pref.getData("name") ?? "";
    } catch (e) {}
    print(" username = $username");

    // If username is empty, show the dialog to get the username
    if (username.isEmpty) {
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
