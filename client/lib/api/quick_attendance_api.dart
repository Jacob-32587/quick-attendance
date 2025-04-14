import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/models/attendance_history_model.dart';
import 'package:quick_attendance/models/group_list_response_model.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/models/group_settings_model.dart';
import 'package:quick_attendance/models/responses/group_attendance_response.dart';
import 'package:quick_attendance/models/responses/login_response.dart';
import 'package:quick_attendance/models/user_model.dart';
import 'package:quick_attendance/util/time.dart';

/// The client for sending requests to the Quick Attendance API
class QuickAttendanceApi extends GetxService {
  /// The dynamic domain and port to support demo
  final RxString domainAndPort = "127.0.0.1:8080".obs;
  final apiClient = BaseApiClient("http://localhost:8080/quick-attendance-api");

  @override
  void onInit() {
    ever(domainAndPort, (newDomainAndPort) {
      apiClient.httpClient.baseUrl =
          "http://$newDomainAndPort/quick-attendance-api";
    });

    super.onInit();
  }

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

  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    Response response = await apiClient.post("/account/login", {
      "email": email,
      "password": password,
    });
    ApiResponse<LoginResponse> apiResponse = ApiResponse(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: LoginResponse.fromJson(response.body),
    );
    return apiResponse;
  }

  Future<ApiResponse<UserModel>> getUser() async {
    // Get the authenticated user's profile
    final Response response = await apiClient.get("/auth/account");
    final UserModel parsedBody = UserModel.fromJson(response.body);
    final apiResponse = ApiResponse(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: parsedBody,
    );
    return apiResponse;
  }

  Future<ApiResponse<UserModel>> updateUserAccount(Map<String, dynamic> data) async {
    final Response response = await apiClient.put("/auth/account", data);
    final apiResponse = ApiResponse<UserModel>(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: UserModel.fromJson(response.body),
    );
    return apiResponse;
}

  Future<GroupModel?> getGroup({required String groupId}) async {
    final Response response = await apiClient.get(
      "/auth/group",
      query: {"group_id": groupId},
    );
    print(response.body.toString());
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
    GroupSettingsModel? settings,
  }) async {
    final Response response = await apiClient.post("/auth/group", {
      "group_name": groupName,
      "group_description": groupDescription,
      "unique_id_settings": settings?.toJson(),
    });
    final apiResponse = ApiResponse(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: GroupModel.fromJson(response.body),
    );
    return apiResponse;
  }

  Future<ApiResponse<Null>> inviteUserToGroup({
    required String username,
    required String groupId,
    required bool inviteAsManager,
  }) async {
    final Response response = await apiClient.put("/auth/group/invite", {
      "usernames": [username],
      "group_id": groupId,
      "is_manager_invite": inviteAsManager,
    });
    final apiResponse = ApiResponse<Null>(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: null,
    );
    return apiResponse;
  }

  Future<ApiResponse<Null>> respondToGroupInvite({
    required String groupInviteJwt,
    required String? uniqueId,
    required bool accept,
  }) async {
    final Response response = await apiClient.put("/auth/account/invite", {
      "account_invite_jwt": groupInviteJwt,
      "unique_id": uniqueId,
      "accept": accept,
    });
    final apiResponse = ApiResponse<Null>(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: null,
    );
    return apiResponse;
  }

  Future<ApiResponse<GroupAttendanceResponse>> getWeeklyGroupAttendance({
    required String? groupId,
    required DateTime? date,
  }) async {
    Map<String, dynamic> query = {"group_id": groupId};
    if (date != null) {
      query["year_num"] = date.year.toString();
      query["month_num"] = date.month.toString();
      query["week_num"] = getWeekOfMonth(date).toString();
    }

    final Response response = await apiClient.get(
      "/auth/attendance/group",
      query: query,
    );

    final apiResponse = ApiResponse<GroupAttendanceResponse>(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: GroupAttendanceResponse.fromJson(response.body),
    );
    return apiResponse;
  }

  Future<ApiResponse<AttendanceHistoryModel>> getWeeklyUserAttendance(
    int? year,
    int? month,
    int? weekOfMonth,
  ) async {
    Map<String, String> query = {};
    if (year != null) {
      query["year_num"] = year.toString();
    }
    if (month != null) {
      // Javascript months start from 0
      query["month_num"] = (month - 1).toString();
    }
    if (weekOfMonth != null) {
      query["week_num"] = weekOfMonth.toString();
    }
    final Response response = await apiClient.get(
      "/auth/attendance/user",
      query: query,
    );

    final apiResponse = ApiResponse<AttendanceHistoryModel>(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: AttendanceHistoryModel.fromJson(response.body),
    );
    return apiResponse;
  }

  Future<ApiResponse<Null>> updateGroup(GroupModel group) async {
    final Response response = await apiClient.put(
      "/auth/group",
      group.toJson(),
    );
    final apiResponse = ApiResponse<Null>(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: null,
    );
    return apiResponse;
  }

  Future<ApiResponse<Null>> startAttendanceSession(String? groupId) async {
    final Response response = await apiClient.post("/auth/attendance", {
      "group_id": groupId,
    });
    final apiResponse = ApiResponse<Null>(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: null,
    );
    return apiResponse;
  }

  Future<ApiResponse<Null>> putAttendedUsers(
    String? groupId,
    List<String> userIds,
  ) async {
    final Response response = await apiClient.put("/auth/attendance", {
      "group_id": groupId,
      "user_ids": userIds,
    });
    final apiResponse = ApiResponse<Null>(
      statusCode: HttpStatusCode.from(response.statusCode),
      body: null,
    );
    return apiResponse;
  }
}
