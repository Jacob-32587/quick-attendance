import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/models/group_list_response_model.dart';
import 'package:quick_attendance/models/user_model.dart';
import 'package:quick_attendance/models/account_settings_model.dart';
import 'package:quick_attendance/models/group_model.dart';

class ProfileController extends GetxController {
  late final QuickAttendanceApi _api = Get.find();
  late final AuthController authController = Get.find();
  var jwt = Rxn<String>();
  var user = Rx<UserModel>(UserModel());
  final userSettings = Rx<AccountSettingsModel>(AccountSettingsModel());
  final _groupListResponse = Rxn<GroupListResponseModel>();
  RxList<GroupModel>? get memberGroups =>
      _groupListResponse.value?.memberGroups;
  RxList<GroupModel>? get managedGroups =>
      _groupListResponse.value?.managedGroups;
  RxList<GroupModel>? get ownedGroups => _groupListResponse.value?.ownedGroups;
  RxBool creatingGroup = false.obs;

  /// Getter for the user's list view preference
  bool get prefersListView => userSettings.value.prefersListView.value;
  // Setter for the user's list view preference
  set prefersListView(bool value) =>
      userSettings.value.prefersListView.value = value;

  String get firstName => user.value.firstName.value;
  String get lastName => user.value.lastName.value;

  @override
  void onInit() {
    super.onInit();

    // Create a listener to the auth controller's logged in status
    ever(authController.isLoggedIn, (loggedIn) {
      if (loggedIn) {
        _fetchProfileData();
      } else {
        _clearProfileData();
      }
    });
  }

  void _fetchProfileData() async {
    Response response = await _api.getAccount();
    if (response.statusCode == 200) {
      user.value = UserModel.fromJson(response.body);
    } else {
      // TODO: Handle failure getting account information
    }
  }

  void _clearProfileData() {
    // Reset user data to empty model
    user.value = UserModel();
  }

  /// Get the groups the user owns, manages, or has joined from the server
  void fetchGroups() async {
    final response = await _api.getUsersGroups();
    if (response.statusCode == HttpStatusCode.ok) {
      _groupListResponse.value = response.body;
    } else {
      // TODO: What should we do when this request fails
    }
  }

  void fetchJoinedGroups() {
    // TODO: Fetch joined groups
  }

  void fetchManagedGroups() {
    // TODO: Fetch managed groups
  }

  void leaveJoinedGroup(String groupId) {
    // TODO: Connect to backend
  }

  void disbandOwnedGroup(String groupId) {
    // TODO: Connect to backend
  }

  void createGroup() async {
    final response = await _api.createGroup(groupName: "Default");
    // Finally
    if (response.statusCode == HttpStatusCode.ok) {
      final String? newGroupId = response.body?.groupId.value;
      if (newGroupId == null) {
        // Should we do something in response to a missing group id?
        return;
      }
      Get.toNamed("/group/$newGroupId");
    }
  }

  void joinGroup(String groupCode) {
    // TODO: Connect to backend
  }
}
