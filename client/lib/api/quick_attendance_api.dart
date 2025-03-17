import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/models/group_list_response_model.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/models/user_type.dart';
import 'package:quick_attendance/pages/home/components/group_list.dart';

/// The client for sending requests to the Attenda Scan API
class QuickAttendanceApi {
  final apiClient = BaseApiClient("http://localhost:8080/quick-attendance-api");

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

  Future<Response> login({required String email, required String password}) {
    return apiClient.post("/account/login", {
      "email": email,
      "password": password,
    });
  }

  Future<Response> getAccount() {
    return apiClient.get("/auth/account");
  }

  Future<GroupModel?> getGroup({
    required String groupId,

    /// In relation to the target group, who does this user claim to be?
    /// This is an optimization to improve request times
    required UserType userTypeClaim,
  }) async {
    final Response response = await apiClient.get(
      "/auth/group",
      query: {"group_id": groupId, "user_type": userTypeClaim.value},
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

  Future<ApiResponse<GroupListResponseModel>> getUsersGroups() async {
    final Response response = await apiClient.get("/auth/group/list");
    final GroupListResponseModel parsedBody = GroupListResponseModel.fromJson(
      response.body,
    );
    final apiResponse = ApiResponse(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: parsedBody,
    );
    return apiResponse;
  }

  /// Create a group owned by the authenticated user.
  /// Returns a partial group model which contains, at the very least,
  /// the id of the group that was created
  Future<ApiResponse<GroupModel>> createGroup({
    required String groupName,
    String? groupDescription,
  }) async {
    final Response response = await apiClient.post("/auth/group", {
      "group_name": groupName,
    });
    final apiResponse = ApiResponse(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: GroupModel.fromJson(response.body),
    );
    return apiResponse;
  }
}
