import 'package:flutter/material.dart';

import 'CacheService.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  var n = "";

  Future<void> _loadData() async {
    CacheService pref = CacheService();

    String? name = await pref.getData("name"); // `await` bilan chaqirish
    print(name);
    setState(() {
      n = name ?? ''; // null bo'lsa, bo'sh qiymat qo'yiladi
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(n)));
  }
}
