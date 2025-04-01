import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/models/responses/login_response.dart';
import 'package:quick_attendance/pages/auth/components/login_form.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          if (authController.isLoggedIn.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("You are already logged in!"),
                  PrimaryButton(
                    text: "Go to Home",
                    onPressed: () => Get.toNamed("/"),
                  ),
                ],
              ),
            );
          } else {
            return LoginForm();
          }
        }),
      ),
    );
  }
}
