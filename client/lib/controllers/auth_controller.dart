import 'package:flutter/material.dart';
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

  /// Loading state for retrieving the JWT from storage
  final isLoadingJwt = false.obs;

  /// The user ID that is stored in the JWT.
  String? get userId => jwtPayload.value?.userId;
  Future<bool> isJwtExpired() async {
    if (jwtPayload.value == null) {
      return true;
    }
    int? exp = jwtPayload.value?.exp;
    if (exp == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp < now;
  }

  /// The logged in status of the user. DO NOT MODIFY OUTSIDE OF AUTH CONTROLLER
  final RxBool isLoggedIn = false.obs;

  /// Tries to get the JWT stored on the device and load it into memory.
  Future<void> _tryGetJwt() async {
    isLoadingJwt.value = true;
    try {
      jwt.value = await _storage.read(key: "jwt_token");
    } catch (e) {
      /// Ignore the exception
    }
    _processSavedJwt();
    isLoadingJwt.value = false;
  }

  void _processSavedJwt() {
    String? token = jwt.value;
    if (token == null || token.isEmpty) {
      jwtPayload.value = null;
      isLoggedIn.value = false;
      return;
    }
    try {
      Map<String, dynamic> decodedJwt = Jwt.parseJwt(token);
      jwtPayload.value = JwtModel.fromJson(decodedJwt);
      isLoggedIn.value = true;
    } catch (e) {
      Get.snackbar(
        "Failed to Login",
        "The token was not processable.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveJwt(String? token) async {
    jwt.value = token;
    try {
      await _storage.write(key: "jwt_token", value: token);
      _processSavedJwt();
    } catch (e) {
      // Ignore the exception
    }
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
