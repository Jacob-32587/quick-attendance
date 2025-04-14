import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/components/alert_card.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/info_card.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer_list.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/group_attendance_view_model.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/models/public_user_model.dart';
import 'package:quick_attendance/models/responses/group_attendance_response.dart';
import 'package:quick_attendance/pages/attendance_group/components/display_users.dart';
import 'package:quick_attendance/pages/attendance_group/components/group_scroll_view.dart';
import 'package:quick_attendance/pages/attendance_group/components/invite_user_popup.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';
import 'package:quick_attendance/util/time.dart';

/// Controller for managing the state of the group attendees page
/// Without a controller, this state would get lost whenever the widget disappears
class GroupAttendeesController extends GetxController {
  late final GroupController _controller = Get.find();
  late final ProfileController _profileController = Get.find();
  String? get currentUserId => _profileController.userId;

  bool get isOwner => _controller.isOwner;
  bool get isManager => _controller.isManager;
  bool get isOwnerOrManager => _controller.isOwnerOrManager;

  Rxn<GroupModel> get group => _controller.group;

  final RxBool showAttendance = false.obs;
}

class GroupAttendees extends StatelessWidget {
  late final GroupAttendeesController _controller = Get.put(
    GroupAttendeesController(),
  );
  GroupAttendees({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ManagementSection(
          isOwner: _controller.isOwner,
          isOwnerOrManager: _controller.isOwnerOrManager,
          showAttendance: _controller.showAttendance,
        ),
        const SizedBox(height: 64),
        Obx(
          () => BinaryChoice(
            choice: _controller.showAttendance.value,
            widget1: _AttendanceSection(),
            widget2: _MembersSection(),
          ),
        ),
      ],
    );
  }
}

class _ManagementSection extends StatelessWidget {
  late final GroupController controller = Get.find();
  final bool isOwner;
  final bool isOwnerOrManager;
  final RxBool showAttendance;

  _ManagementSection({
    required this.isOwner,
    required this.isOwnerOrManager,
    required this.showAttendance,
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
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              OutlinedButton.icon(
                label: Obx(
                  () => Text(
                    showAttendance.value
                        ? "View Members"
                        : "View Attendance Records",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                icon: Obx(
                  () => Icon(
                    showAttendance.value ? Icons.group : Icons.history,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
                onPressed: showAttendance.toggle,
              ),
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
  late final GroupController _controller = Get.find();

  List<PublicUserModel> get allMembers {
    List<PublicUserModel> combined = [];

    final owner = _controller.group.value?.owner.value;
    if (owner != null) {
      combined.add(owner);
    }
    final managers = _controller.group.value?.managers;
    if (managers != null) {
      combined.addAll(managers);
    }
    final members = _controller.group.value?.members;
    if (members != null) {
      combined.addAll(members);
    }
    return combined;
  }

  _MembersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DisplayUsers(
          hasLoaded: _controller.hasLoadedGroup,
          isLoading: _controller.isLoadingGroup,
          emptyMessage: "There are no members in this group.",
          title: "Members",
          users: allMembers,
        ),
        const SizedBox(height: 64),
        DisplayUsers(
          title: "Pending Invites",
          emptyMessage: "There are no pending invites.",
          isLoading: _controller.isLoadingGroup,
          hasLoaded: _controller.hasLoadedGroup,
          users: _controller.group.value?.pendingMembers,
        ),
      ],
    );
  }
}

/// Controller for managing state of the Attendance Section
class _AttendanceController extends GetxController {
  late final GroupController _groupController = Get.find();
  final QuickAttendanceApi _api = Get.find();
  final attendanceData = Rxn<GroupAttendanceResponse>();

  // Some state variables for viewing attendance
  final RxBool failedToGetAttendance = false.obs;
  final RxBool isLoadingAttendance = false.obs;
  final RxBool hasLoadedAttendance = false.obs;
  final Rx<DateTime> attendanceDate = Rx<DateTime>(DateTime.now());
  String? _lastDateKey;

  List<GroupAttendanceViewModel> get filteredAttendance {
    final selected = selectedDate.value;
    var result =
        attendanceData.value?.attendance?.where((entry) {
          final time = entry.attendanceStartTime.value;
          return time?.year == selected.year &&
              time?.month == selected.month &&
              time?.day == selected.day;
        }).toList() ??
        [];
    print("Session count: ${result.length}");
    return result;
  }

  Future<void> getAttendance() async {
    failedToGetAttendance.value = false;
    isLoadingAttendance.value = true;
    hasLoadedAttendance.value = false;
    var response = await _api.getWeeklyGroupAttendance(
      groupId: _groupController.groupId,
      date: null,
    );
    if (response.statusCode != HttpStatusCode.ok) {
      failedToGetAttendance.value = true;
      attendanceData.value = null;
    } else {
      attendanceData.value = response.body;
    }
    isLoadingAttendance.value = false;
    hasLoadedAttendance.value = true;
  }

  void checkDate() {
    final currentKey = dateKey;
    if (currentKey != _lastDateKey) {
      _lastDateKey = currentKey;
      print("New week selected");
      getAttendance();
    }
  }

  final Rx<DateTime> selectedDate = Rx<DateTime>(DateTime.now());
  String get dateKey {
    final date = selectedDate.value;
    final week = getWeekOfMonth(date);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-$week';
  }

  @override
  void onInit() {
    super.onInit();
    checkDate();
    ever(selectedDate, (_) {
      checkDate();
    });
  }
}

class _AttendanceSection extends StatelessWidget {
  final _AttendanceController _attendanceController = Get.put(
    _AttendanceController(),
  );

  _AttendanceSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => EasyDateTimeLinePicker(
            focusedDate: _attendanceController.selectedDate.value,
            physics: BouncingScrollPhysics(),
            firstDate: DateTime(2025, 1, 1),
            lastDate: DateTime.now(),
            selectionMode: SelectionMode.autoCenter(),
            onDateChange: (date) {
              _attendanceController.selectedDate.value = date;
            },
          ),
        ),
        const SizedBox(height: 32),
        Obx(() {
          var isLoading = _attendanceController.isLoadingAttendance.value;
          var failedToRetrieve =
              _attendanceController.failedToGetAttendance.value;
          final filteredList = _attendanceController.filteredAttendance;
          if (isLoading) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonShimmer(
                  isLoading: true.obs,
                  skeletonHeight: 25,
                  skeletonWidth: 250,
                ),
                const SizedBox(height: 12),
                SkeletonShimmerList(
                  isLoading: true.obs,
                  skeletonWidth: 400,
                  skeletonHeight: 65,
                ),
              ],
            );
          } else if (failedToRetrieve) {
            return AlertCard(
              child: Text(
                "Sorry, we failed to retrieve attendance records from the server. Try again later.",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (filteredList.isEmpty) {
            return InfoCard(
              child: Text(
                "There were no sessions on this day",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          // Display attendance records for the selected date
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(filteredList.length, (index) {
              final attendance = filteredList[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Session ${index + 1} (${displayTimeOfDateTime(attendance.attendanceStartTime.value)}-${displayTimeOfDateTime(attendance.attendanceEndTime.value)})",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  DisplayUsers(
                    isLoading: _attendanceController.isLoadingAttendance,
                    hasLoaded: _attendanceController.hasLoadedAttendance,
                    emptyMessage: "No members attended this session",
                    displayAttended: true,
                    users: attendance.attendees,
                  ),
                  const SizedBox(height: 40),
                ],
              );
            }),
          );
        }),
      ],
    );
  }
}
