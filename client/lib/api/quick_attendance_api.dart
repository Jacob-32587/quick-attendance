import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/models/group_model.dart';

/// The client for sending requests to the Attenda Scan API
class QuickAttendanceApi {
  final apiClient = BaseApiClient("http://localhost:8080/quick-scan-api");

  /// Example
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

  Future<GroupModel?> getGroup({required String groupId}) async {
    final Response response = await apiClient.get(
      "",
      query: {"groupId": groupId},
    );
    if (response.statusCode == 200) {
      return GroupModel.fromJson(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        "Server failed to determine if group: '$groupId' exists.",
      );
    }
  }
}
