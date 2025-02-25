import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/pages/auth/login.dart';
import 'package:quick_attendance/pages/home/home.dart';

class AuthGate extends StatelessWidget {
  final AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return authController.isLoggedIn.value ? HomePage() : Login();
    });
  }
}
