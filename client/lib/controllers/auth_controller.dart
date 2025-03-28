import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/models/jwt_model.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final QuickAttendanceApi api = Get.find();

  /// The JWT providing request Authorization and the logged in status
  final jwt = Rxn<String>();
  final jwtPayload = Rxn<JwtModel>();

  /// The user ID that is stored in the JWT.
  String? get userId => jwtPayload.value?.userId;
  bool get isJwtExpired {
    if (jwtPayload.value == null) {
      return false;
    }
    int? exp = jwtPayload.value?.exp;
    if (exp == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return exp < now;
  }

  /// The logged in status of the user. DO NOT MODIFY OUTSIDE OF AUTH CONTROLLER
  final RxBool isLoggedIn = false.obs;

  /// Tries to get the JWT stored on the device and load it into memory.
  Future<void> _tryGetJwt() async {
    jwt.value = await _storage.read(key: "jwt_token");
    _processSavedJwt();
  }

  void _processSavedJwt() {
    String? token = jwt.value;
    if (token == null || token.isEmpty) {
      jwtPayload.value = null;
      isLoggedIn.value = false;
      Get.toNamed("/login");
      return;
    }
    try {
      Map<String, dynamic> decodedJwt = Jwt.parseJwt(token);
      jwtPayload.value = JwtModel.fromJson(decodedJwt);
      isLoggedIn.value = true;
    } catch (e) {
      Get.snackbar(
        "Failed to Login",
        "The response from the server was not processable.",
      );
      Get.toNamed("login");
    }
  }

  Future<void> saveJwt(String? token) async {
    jwt.value = token;
    await _storage.write(key: "jwt_token", value: token);
    _processSavedJwt();
  }

  void logout() {
    isLoggedIn.value = false;
    saveJwt(null);
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
    _tryGetJwt();
  }
}
