import 'package:chtapp/bottom_bar/status_list.dart';
import 'package:flutter/material.dart';

class StatusTabScreen extends StatefulWidget {
  const StatusTabScreen({super.key});

  @override
  State<StatusTabScreen> createState() => _StatusTabScreenState();
}

class _StatusTabScreenState extends State<StatusTabScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFDFFEF4), // ✅ Light greenish blue color

        appBar: AppBar(
          backgroundColor: const Color(0xFFDFFEF4), // ✅ Light greenish blue color

          title: const Text("Request Status"),
    centerTitle: true,
    bottom: const TabBar(
    indicatorColor: Colors.white,
    tabs: [
    Tab(text: "Pending"),
    Tab(text: "Active"),
    Tab(text: "Completed"),
    ],
    ),

      ),
        body: TabBarView(
            children: [
              StatusList(status: "pending"),
              StatusList(status: "active"),
              StatusList(status: "completed"),
            ]
        ),

      )
    );
  }
}
