import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

/// Should be used to wrap pages that need authentication before
/// doing anything on the page. This widget provides a centered loading
/// indicator while the user JWT is being retrieved. Often times,
/// this page may not even be visible, but without it the user would momentarily
/// be unauthenticated and race conditions could occur.
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
