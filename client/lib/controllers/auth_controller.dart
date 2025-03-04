import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  void login() {
    isLoggedIn.value = true;
    // This is NOT base flutter functionality.
    // This requires use of the "get" package.
    // refer to main.dart for existing routes.
    Get.toNamed("/home");
  }

  void logout() {
    isLoggedIn.value = false;
    Get.toNamed("/login");
  }

  bool signUp(
    String email,
    String username,
    String firstName,
    String lastName,
    String password,
  ) {
    login();
    return true;
  }
}
