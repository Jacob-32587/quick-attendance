import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

class AuthGate extends StatelessWidget {
  final AuthController authController = Get.find();
  final Widget page;

  AuthGate({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (authController.isLoadingJwt.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      } else if (!authController.isLoggedIn.value) {
        Future.microtask(() => Get.offAllNamed("/login"));
        return const SizedBox.shrink();
      }
      return page;
    });
  }
}
