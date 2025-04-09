import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/models/group_list_response_model.dart';
import 'package:quick_attendance/models/group_settings_model.dart';
import 'package:quick_attendance/models/user_model.dart';
import 'package:quick_attendance/models/account_settings_model.dart';
import 'package:quick_attendance/models/group_model.dart';

class HistoryController extends GetxController {
  late final QuickAttendanceApi _api = Get.find();
  late final AuthController authController = Get.find();
  var jwt = Rxn<String>();
  Future<void>? futureUser;
  final userSettings = Rx<AccountSettingsModel>(AccountSettingsModel());
  final _groupListResponse = Rxn<GroupListResponseModel>();

  RxList<GroupModel>? get memberGroups =>
      _groupListResponse.value?.memberGroups;
  RxList<GroupModel>? get managedGroups =>
      _groupListResponse.value?.managedGroups;
  RxList<GroupModel>? get ownedGroups => _groupListResponse.value?.ownedGroups;

  /// Loading state for fetching group list information
  final RxBool isLoadingHistory = false.obs;
  final RxBool hasLoadedHistory = false.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  /// Get the groups the user owns, manages, or has joined from the server
  Future<void> getAttendanceHistoryForWeek() async {
    isLoadingHistory.value = true;
    final response = await _api.getUsersGroups();
    if (response.statusCode == HttpStatusCode.ok) {
      hasLoadedHistory.value = true;
      _groupListResponse.value = response.body;
    } else {
      // TODO: What should we do when this request fails
    }
    isLoadingHistory.value = false;
  }
}
