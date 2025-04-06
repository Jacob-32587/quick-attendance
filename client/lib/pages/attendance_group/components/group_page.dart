import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/pages/attendance_group/attendance_session_screen.dart';
import 'package:quick_attendance/pages/attendance_group/attendees_screen.dart';
import 'package:quick_attendance/pages/attendance_group/group_home_screen.dart';

/// Handles the logic for retrieving group information
class GroupController extends GetxController {
  late final QuickAttendanceApi _api = Get.find();
  late final GroupController groupController;
  String? get groupId => group.value?.groupId.value;
  final RxBool isLoadingGroup = RxBool(true);
  final RxBool isEditingGroup = RxBool(false);
  final RxBool hasLoadedGroup = RxBool(false);

  /// The active group being accessed
  final group = Rxn<GroupModel>();

  /// Fetch group information for the provided group id
  void fetchGroup(String? groupId) async {
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
}

/// The parent page for attendance group pages which
/// handles navigation between them.
class GroupPage extends StatelessWidget {
  late final GroupController _controller = Get.put(GroupController());

  final RxInt _currentIndex = 1.obs;

  GroupPage({super.key});

  late final PageController _pageController = PageController(
    initialPage: _currentIndex.value,
  );

  void changePage(int index) {
    _currentIndex.value = index;
    _pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    _currentIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final String? groupId = Get.parameters["groupId"];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (groupId != _controller.groupId) {
        _controller.fetchGroup(groupId);
      }
    });
    return Obx(
      () => Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: [
            GroupAttendeesScreen(),
            GroupHomeScreen(),
            GroupAttendanceSessionScreen(group: _controller.group),
          ],
        ),
        bottomNavigationBar:
            _controller.group.value == null
                ? null
                : BottomNavigationBar(
                  currentIndex: _currentIndex.value,
                  onTap: changePage,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Theme.of(context).colorScheme.onSurface,
                  enableFeedback: true,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.group),
                      label: "Members",
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.calendar_today),
                      label: "Attend",
                    ),
                  ],
                ),
      ),
    );
  }
}
