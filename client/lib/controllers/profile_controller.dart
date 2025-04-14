import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/models/group_list_response_model.dart';
import 'package:quick_attendance/models/group_settings_model.dart';
import 'package:quick_attendance/models/pending_invite_jwt_model.dart';
import 'package:quick_attendance/models/user_model.dart';
import 'package:quick_attendance/models/account_settings_model.dart';
import 'package:quick_attendance/models/group_model.dart';

class ProfileController extends GetxController {
  late final QuickAttendanceApi _api = Get.find();
  late final AuthController authController = Get.find();
  var jwt = Rxn<String>();
  var user = Rxn<UserModel>();
  Future<void>? futureUser;
  final userSettings = Rx<AccountSettingsModel>(AccountSettingsModel());
  final _groupListResponse = Rxn<GroupListResponseModel>();

  RxList<GroupModel>? get memberGroups =>
      _groupListResponse.value?.memberGroups;
  RxList<GroupModel>? get managedGroups =>
      _groupListResponse.value?.managedGroups;
  RxList<GroupModel>? get ownedGroups => _groupListResponse.value?.ownedGroups;

  RxList<PendingInviteJwtModel>? get pendingGroupJwts =>
      user()?.pendingGroupJwts;

  /// Loading state for creating a group
  final RxBool isCreatingGroup = false.obs;

  /// Loading state for fetching group list information
  final RxBool isLoadingGroups = false.obs;
  final RxBool hasLoadedGroups = false.obs;

  /// Getter for the user's list view preference
  bool get prefersListView => userSettings.value.prefersListView.value;
  // Setter for the user's list view preference
  set prefersListView(bool value) =>
      userSettings.value.prefersListView.value = value;

  /// Get the user's first name or empty string
  String get firstName => user()?.firstName() ?? "";

  /// Get the user's last name or empty string
  String get lastName => user()?.lastName() ?? "";

  // Get the user's username or empty string
  String get username => user()?.username() ?? "";

  // Get the user's email or empty string
  String get email => user()?.email() ?? "";

  String? get userId => user()?.userId();

  @override
  void onInit() {
    super.onInit();

    // Create a listener to the auth controller's logged in status
    ever(authController.isLoggedIn, (loggedIn) {
      if (loggedIn) {
        futureUser = fetchProfileData();
        fetchGroups();
      } else {
        _clearProfileData();
      }
    });
  }

  Future<void> fetchProfileData() async {
    final response = await _api.getUser();
    if (response.statusCode == HttpStatusCode.ok) {
      user.value = response.body;
    } else {
      // TODO: Handle failure getting account information
    }
  }

  void _clearProfileData() {
    // Reset user data to empty model
    user.value = UserModel();
  }

  Future<void> updateUserAccount({
    required String username,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _api.updateUserAccount({
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    });

    if (response.statusCode == HttpStatusCode.ok) {
      user.value = response.body;
    } else {
      // TODO: Show error message or log issue
    }
  }

  /// Get the groups the user owns, manages, or has joined from the server
  Future<void> fetchGroups() async {
    isLoadingGroups.value = true;
    final response = await _api.getUsersGroups();
    if (response.statusCode == HttpStatusCode.ok) {
      hasLoadedGroups.value = true;
      _groupListResponse.value = response.body;
    } else {
      // TODO: What should we do when this request fails
    }
    isLoadingGroups.value = false;
  }

  void leaveJoinedGroup(String groupId) {
    // TODO: Connect to backend
  }

  void disbandOwnedGroup(String groupId) {
    // TODO: Connect to backend
  }

  /// Attempts to create a group and then navigate to its page
  Future<String?> createGroup({GroupSettingsModel? settings}) async {
    final response = await _api.createGroup(groupName: "Default");
    if (response.statusCode == HttpStatusCode.ok) {
      fetchGroups();
      final String? newGroupId = response.body?.groupId.value;
      if (newGroupId == null) {
        // Should we do something in response to a missing group id?
        return null;
      }
      return newGroupId;
    }
    return null;
  }

  Future<void> respondToInvite({
    required String groupInviteJwt,
    required String? uniqueId,
    required bool accept,
  }) async {
    var ret = await _api.respondToGroupInvite(
      groupInviteJwt: groupInviteJwt,
      uniqueId: uniqueId,
      accept: accept,
    );
    if (!ret.isSuccess) {
      // TODO Add error handling
    }
    fetchProfileData();
    fetchGroups();
  }
}
