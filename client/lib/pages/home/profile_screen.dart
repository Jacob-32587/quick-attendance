import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/profile_header.dart';
import 'package:quick_attendance/pages/home/components/profile_info.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        elevation: 2.0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shadowColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: Obx ( () => ProfileHeader(
              name: '${profileController.user.value?.firstName() ?? ""} ${profileController.user.value?.lastName() ?? ""}',
              user: profileController.user.value?.username() ?? "",
              email: profileController.user.value?.email() ?? "",
            )),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: Obx( () => ProfileInfo(
              firstName: profileController.user.value?.firstName() ?? "",
              lastName: profileController.user.value?.lastName() ?? "",
              user: profileController.user.value?.username() ?? "",
              email: profileController.user.value?.email() ?? "",
              groups: profileController.memberGroups
            )),
          ),
          SizedBox(height: 20),
          PrimaryButton(text: "Logout", onPressed: authController.logout),
        ]
      ),
    );
  }
}