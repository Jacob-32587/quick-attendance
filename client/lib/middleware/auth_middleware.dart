import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  late final AuthController _authController = Get.find();
  @override
  RouteSettings? redirect(String? route) {
    if (_authController.isJwtExpired) {
      return const RouteSettings(name: "/login");
    }
    return null;
  }
}
