import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

class BaseApiClient extends GetConnect {
  late final AuthController _authController = Get.find();
  BaseApiClient(String baseUrl) {
    this.baseUrl = baseUrl;
  }

  @override
  void onInit() {
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
