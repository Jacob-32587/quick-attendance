import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final QuickAttendanceApi api = Get.find();

  /// The JWT providing request Authorization and the logged in status
  var jwt = Rxn<String>();

  /// The user ID that is stored in the JWT.
  final RxnString userId = RxnString();

  /// The logged in status of the user. DO NOT MODIFY OUTSIDE OF AUTH CONTROLLER
  final RxBool isLoggedIn = false.obs;

  Future<void> _tryGetJwt() async {
    jwt.value = await _storage.read(key: "jwt_token");
  }

  Future<void> _saveJwt(String? token) async {
    await _storage.write(key: "jwt_token", value: token);
  }

  void logout() {
    isLoggedIn.value = false;
    _saveJwt(null);
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
      _saveJwt(newJwt);
      if (newJwt == null || newJwt.isEmpty) {
        userId.value = null;
        isLoggedIn.value = false;
        // TODO: Redirect user to login screen and notify them about the problem
        return;
      }
      try {
        var decodedJwt = Jwt.parseJwt(newJwt);
        userId.value = decodedJwt["user_id"];
        isLoggedIn.value = true;
      } catch (e) {
        Get.log("Failed to decode JWT: '$newJwt' : $e");
        userId.value = null;
      }
    });
    _tryGetJwt();
  }
}
