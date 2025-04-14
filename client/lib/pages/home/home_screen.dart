import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/controllers/history_controller.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find();
  final ProfileController profileController = Get.find();
  final HistoryController _historyController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _historyController.onRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  "Hello, ${profileController.firstName}",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Welcome back! Here's what's happening right now.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 24),

              // Give HistoryScreen a defined height
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: HistoryScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
