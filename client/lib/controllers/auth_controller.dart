import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  var jwt = Rxn<String>();
  var isLoggedIn = false.obs;

  Future<void> _tryGetJwt() async {
    jwt.value = await _storage.read(key: "jwt_token");
  }

  Future<void> _saveJwt(String token) async {
    await _storage.write(key: "jwt_token", value: token);
  }

  void login() {
    isLoggedIn.value = true;

    // TODO: Set the JWT from the returned promise

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

  @override
  void onInit() {
    super.onInit();
    _tryGetJwt();
  }
}
