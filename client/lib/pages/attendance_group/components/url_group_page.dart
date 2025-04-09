import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/models/responses/group_attendance_response.dart';

/// Handles the logic for retrieving group information
class GroupController extends GetxController {
  late final QuickAttendanceApi _api = Get.find();
  late final GroupController groupController;
  String? get groupId => group.value?.groupId.value;
  final RxBool isLoadingGroup = RxBool(true);
  final RxBool isEditingGroup = RxBool(false);
  final RxBool hasLoadedGroup = RxBool(false);

  // Some state variables for viewing member attendance
  final RxBool isLoadingAttendance = false.obs;
  final RxBool hasLoadedAttendance = false.obs;
  final Rx<DateTime> attendanceDate = Rx<DateTime>(DateTime.now());

  /// The active group being accessed
  final group = Rxn<GroupModel>();

  /// Fetch group information for the provided group id
  Future<void> fetchGroup(String? groupId) async {
    if (groupId == null) {
      isLoadingGroup.value = false;
      return;
    }
    isLoadingGroup.value = true;
    final group = await _api.getGroup(groupId: groupId);
    if (group == null) {
      this.group.value = null;
    } else {
      this.group.value = group;
    }
    hasLoadedGroup.value = true;
    isLoadingGroup.value = false;
  }

  Future<ApiResponse<Null>?> inviteUserToGroup(
    String username,
    bool inviteAsManager,
  ) async {
    if (groupId == null) {
      return null;
    }
    return await _api.inviteUserToGroup(
      username: username,
      groupId: groupId!,
      inviteAsManager: inviteAsManager,
    );
  }

  /// Get the group's weekly attendance records.
  Future<ApiResponse<GroupAttendanceResponse>>
  getWeeklyGroupAttendance() async {
    isLoadingAttendance.value = true;
    ApiResponse<GroupAttendanceResponse> response = await _api
        .getWeeklyGroupAttendance(groupId: groupId, date: null);
    isLoadingAttendance.value = false;
    hasLoadedAttendance.value = true;
    return response;
  }
}

/// A basic class for retrieving a :groupId from the route
/// parameters and attempts to retrieve the group from the server.
/// Handles reactively retrieving the group when the URL parameter changes.
abstract class UrlGroupPage extends StatelessWidget {
  late final GroupController _controller = Get.put(GroupController());

  UrlGroupPage({super.key});

  Widget buildWithController(BuildContext context, GroupController controller);

  @override
  Widget build(BuildContext context) {
    final String? groupId = Get.parameters["groupId"];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (groupId != _controller.groupId) {
        _controller.fetchGroup(groupId);
      }
    });
    return buildWithController(context, _controller);
  }
}
