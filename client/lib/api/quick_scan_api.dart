import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

/// The client for sending requests to the Attenda Scan API
class QuickScanApi extends GetConnect {
  late final AuthController _authController = Get.find();

  /// Example client
  Future<Response> getData({required String groupCode}) async {
    return await get("/foobar/za", query: {"groupCode": groupCode});
  }

  Future<Response> signup({
    required String email,
    required String username,
    required String firstName,
    String? lastName,
    required String password,
  }) {
    return post("/account", {
      "email": email,
      "username": username,
      "first_name": firstName,
      "last_name": lastName,
      "password": password,
    });
  }

  @override
  void onInit() {
    // TODO: Use environment variables for the base url
    httpClient.baseUrl = "http://localhost:8080/quick-scan-api";
    httpClient.defaultContentType = "application/json";
    // Add interceptor
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers["Authorization"] = "Bearer ${_authController}";
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      // TODO: Handle unauthorized (401) status codes navigating to login page.
      return response;
    });

    super.onInit();
  }
}
