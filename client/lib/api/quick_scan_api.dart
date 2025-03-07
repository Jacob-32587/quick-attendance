import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

/// The client for sending requests to the Attenda Scan API
class QuickScanApi {
  final apiClient = BaseApiClient("http://localhost:8080/quick-scan-api");

  /// Example client
  Future<Response> getData({required String groupCode}) async {
    return await apiClient.get("/foobar/za", query: {"groupCode": groupCode});
  }

  Future<Response> signup({
    required String email,
    required String username,
    required String firstName,
    String? lastName,
    required String password,
  }) {
    return apiClient.post("/account", {
      "email": email,
      "username": username,
      "first_name": firstName,
      "last_name": lastName,
      "password": password,
    });
  }
}
