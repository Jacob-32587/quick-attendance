import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

/// The client for sending requests to the Attenda Scan API
class AttendaScanApi extends GetConnect {
  late final AuthController _authController = Get.find();

  /// Example client
  Future<Response> getData({required String groupCode}) async {
    return await get("/foobar/za", query: {"groupCode": groupCode});
  }

  @override
  void onInit() {
    httpClient.baseUrl = "";

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
