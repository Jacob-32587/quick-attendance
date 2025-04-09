import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/group_attendance_view_model.dart';
import 'package:quick_attendance/models/public_user_model.dart';
import 'package:quick_attendance/models/responses/group_attendance_response.dart';
import 'package:quick_attendance/pages/attendance_group/components/display_users.dart';
import 'package:quick_attendance/pages/attendance_group/components/group_scroll_view.dart';
import 'package:quick_attendance/pages/attendance_group/components/invite_user_popup.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';
import 'package:quick_attendance/util/time.dart';

class GroupAttendeesScreen extends StatelessWidget {
  late final GroupController _controller = Get.find();
  late final ProfileController _profileController = Get.find();

  String? get currentUserId => _profileController.user.value?.userId.value;
  bool get isOwnerOrManager {
    return isManager || isOwner;
  }

  final RxBool showAttendance = false.obs;

  bool get isManager {
    final group = _controller.group.value;
    if (group == null || currentUserId == null) {
      return false;
    }
    if (group.managers?.any((user) => user.userId.value == currentUserId) ==
        true) {
      return true;
    }
    return false;
  }

  bool get isOwner {
    final group = _controller.group.value;
    if (group == null || currentUserId == null) {
      return false;
    }
    if (group.owner.value?.userId.value == currentUserId) {
      return true;
    }
    return false;
  }

  GroupAttendeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupPageContainer(
      title: _controller.group.value?.name.value ?? "Unknown Group",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ManagementSection(
            controller: _controller,
            isOwner: isOwner,
            isOwnerOrManager: isOwnerOrManager,
            onViewAttendance: () => showAttendance.toggle(),
          ),
          const SizedBox(height: 64),
          Obx(
            () => BinaryChoice(
              choice: showAttendance.value,
              widget1: _AttendanceSection(controller: _controller),
              widget2: _MembersSection(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementSection extends StatelessWidget {
  final GroupController controller;
  final bool isOwner;
  final bool isOwnerOrManager;
  final void Function() onViewAttendance;

  const _ManagementSection({
    required this.controller,
    required this.isOwner,
    required this.isOwnerOrManager,
    required this.onViewAttendance,
  });

  @override
  Widget build(BuildContext context) {
    if (isOwnerOrManager) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Manage",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                label: Text(
                  "View Attendance Records",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                icon: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                ),
                onPressed: onViewAttendance,
              ),
              const SizedBox(width: 20),
              if (isOwner)
                OutlinedButton.icon(
                  label: Text(
                    "Invite User",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  icon: Icon(
                    Icons.person_add,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  ),
                  onPressed: () {
                    showInviteUserPopup(context);
                  },
                ),
            ],
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

/// Widget for displaying the list of members and pending members
class _MembersSection extends StatelessWidget {
  final GroupController controller;

  List<PublicUserModel> get allMembers {
    List<PublicUserModel> combined = [];

    final owner = controller.group.value?.owner.value;
    if (owner != null) {
      combined.add(owner);
    }
    final managers = controller.group.value?.managers;
    if (managers != null) {
      combined.addAll(managers);
    }
    final members = controller.group.value?.members;
    if (members != null) {
      combined.addAll(members);
    }
    return combined;
  }

  const _MembersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DisplayUsers(
          hasLoaded: controller.hasLoadedGroup,
          isLoading: controller.isLoadingGroup,
          emptyMessage: "There are no members in this group.",
          title: "Members",
          users: allMembers,
        ),
        const SizedBox(height: 64),
        DisplayUsers(
          title: "Pending Invites",
          emptyMessage: "There are no pending invites.",
          isLoading: controller.isLoadingGroup,
          hasLoaded: controller.hasLoadedGroup,
          users: controller.group.value?.pendingMembers,
        ),
      ],
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  final GroupController controller;

  final attendanceData = Rxn<GroupAttendanceResponse>();
  final RxBool failedToGetAttendance = false.obs;

  GroupAttendanceViewModel? get activeAttendance =>
      attendanceData.value?.attendance?[0];

  DateTime? get activeDate => activeAttendance?.attendanceTime.value;
  String get formattedDate => formatDate(activeDate);

  _AttendanceSection({required this.controller}) {
    getAttendance();
  }

  Future<void> getAttendance() async {
    failedToGetAttendance.value = false;
    var response = await controller.getWeeklyGroupAttendance();
    if (response.statusCode != HttpStatusCode.ok) {
      failedToGetAttendance.value = true;
      attendanceData.value = null;
      return;
    }
    attendanceData.value = response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => DisplayUsers(
            title: "Attendees on $formattedDate",
            isLoading: controller.isLoadingAttendance,
            hasLoaded: controller.hasLoadedAttendance,
            emptyMessage: "No members attended this session.",
            users: attendanceData.value?.attendance?[0].attendees,
            displayLoadingTitle: true,
            displayAttended: true,
          ),
        ),
      ],
    );
  }
}
