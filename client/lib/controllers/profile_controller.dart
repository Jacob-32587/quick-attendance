import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/models/account_model.dart';
import 'package:quick_attendance/models/account_settings_model.dart';
import 'package:quick_attendance/models/group_model.dart';

class ProfileController extends GetxController {
  late final AuthController authController = Get.find();
  var jwt = Rxn<String>();
  var user = Rx<AccountModel>(AccountModel());
  var userSettings = Rx<AccountSettingsModel>(AccountSettingsModel());
  var joinedGroups = RxList<GroupModel>([]);
  var managedGroups = RxList<GroupModel>([]);
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

  void _fetchProfileData() {
    // TODO: Fetch account model
    // TODO: Fetch account settings
  }

  void _clearProfileData() {}

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

  void createGroup() {
    creatingGroup.value = true;
    // TODO: Connect to backend
    managedGroups.add(
      GroupModel(name: "Default", description: "Default description"),
    );
    // TODO: Figure out how to notify the user group creation failed
    // I don't think we need a success notification, it should automatically
    // navigate to the new group's page.
    creatingGroup.value = false;
  }

  void joinGroup(String groupCode) {
    // TODO: Connect to backend
  }
}
