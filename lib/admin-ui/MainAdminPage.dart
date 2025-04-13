import 'package:flutter/material.dart';
import 'package:quiz_bot/admin-ui/CreateExamListPage.dart';

import 'GroupExamList.dart';

class MainAdminPage extends StatefulWidget {
  const MainAdminPage({super.key});

  @override
  State<MainAdminPage> createState() => _MainAdminPageState();
}

class _MainAdminPageState extends State<MainAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            dividerColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.home, color: Colors.white)),

              Tab(icon: Icon(Icons.group, color: Colors.white)),
            ],
          ),
          title: const Text(
            'Admin panel',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [CreateExamListPage(), GroupListPage()],
        ),
      ),
    );
  }
}
