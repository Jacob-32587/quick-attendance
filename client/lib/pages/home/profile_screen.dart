import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.find();
  final AuthController authController = Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          elevation: 2.0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shadowColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: ProfileHeader(
                name: '${profileController.firstName} ${profileController.lastName}',
                user: '${profileController.username}',
                email: '${profileController.email}',
              ),
            ),
            PrimaryButton(text: "Logout", onPressed: authController.logout),
          ]
        )
      );
    });
  }
}
// 