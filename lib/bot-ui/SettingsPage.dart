import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'CacheService.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  final TextEditingController _usernameController = TextEditingController();
  String selectedLanguage = 'Uzbek';
  String selectedGroup = 'A';

  final Map<String, String> languages = {
    'Uzbek': '🇺🇿 Uzbek',
    'English': '🇺🇸 English',
    'Russian': '🇷🇺 Russian',
  };
  String name = "";
  String group = "";
  String language = "";
  List<String> groups = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loadData() async {
    CacheService pref = CacheService();
    final querySnapshot = await _firestore.collection('groups').get();

    for (var doc in querySnapshot.docs) {
      groups.add(doc['title']); // Adding group IDs to the list
    }
    name = window.localStorage["name"]!;
    group = (await pref.getData("group"))!;
    language = (await pref.getData("lan"))!;

    setState(() {
      _usernameController.text = name ?? '';
      selectedLanguage = language ?? 'Uzbek';
      selectedGroup = group ?? 'A';
    });
  }

  Future<void> _saveData() async {
    CacheService pref = CacheService();
    await pref.saveData("name", _usernameController.text);
    await pref.saveData("lan", selectedLanguage);
    await pref.saveData("group", selectedGroup);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedLanguage == "Uzbek"
              ? "Ma'lumotlar saqlandi"
              : selectedLanguage == "English"
              ? "Data has been saved"
              : "Данные сохранены",
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  InputDecoration _customDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          selectedLanguage == "Uzbek"
              ? "Sozlamalar"
              : selectedLanguage == "English"
              ? "Settings"
              : "Настройки",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Username
            Container(
              decoration: _softCard(),
              child: TextField(
                controller: _usernameController,
                decoration: _customDecoration(
                  selectedLanguage == "Uzbek"
                      ? "Foydalanuvchi nomi"
                      : selectedLanguage == "English"
                      ? "Username"
                      : "Имя пользователя",
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Group selection
            Container(
              decoration: _softCard(),
              child: DropdownButtonFormField<String>(
                value: selectedGroup,
                decoration: _customDecoration(
                  selectedLanguage == "Uzbek"
                      ? "Guruh"
                      : selectedLanguage == "English"
                      ? "Group"
                      : "Группа",
                ),
                items:
                    groups.map((group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGroup = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Language selection
            Container(
              decoration: _softCard(),
              child: DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: _customDecoration(
                  selectedLanguage == "Uzbek"
                      ? "Til"
                      : selectedLanguage == "English"
                      ? "Language"
                      : "Язык",
                ),
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
                  });
                },
              ),
            ),
            const SizedBox(height: 30),

            // Save button
            ElevatedButton.icon(
              onPressed: _saveData,
              icon: const Icon(Icons.save),
              label: Text(
                selectedLanguage == "Uzbek"
                    ? "Saqlash"
                    : selectedLanguage == "English"
                    ? "Save"
                    : "Сохранить",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _softCard() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(
          color: Color(0xFFdce1e6),
          offset: Offset(4, 4),
          blurRadius: 8,
        ),
        BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
      ],
    );
  }
}
