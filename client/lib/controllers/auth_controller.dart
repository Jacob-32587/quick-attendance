import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:quick_attendance/api/quick_scan_api.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final QuickScanApi api = Get.find();
  var jwt = Rxn<String>();

  /// The user ID that is stored in the JWT
  var userId = Rxn<String>();
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

  Future<Response> signUp(
    String email,
    String username,
    String firstName,
    String lastName,
    String password,
  ) async {
    return api.signup(
      email: email,
      username: username,
      firstName: firstName,
      lastName: lastName,
      password: password,
    );
  }

  @override
  void onInit() {
    super.onInit();
    ever(jwt, (newJwt) {
      if (newJwt == null || newJwt.isEmpty) {
        userId.value = null;
        return;
      }
      try {
        var decodedJwt = Jwt.parseJwt(newJwt);
        userId.value = decodedJwt["user_id"];
      } catch (e) {
        Get.log("Failed to decode JWT: '$newJwt' : $e");
        userId.value = null;
      }
    });
    _tryGetJwt();
  }
}
