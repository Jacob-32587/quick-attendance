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
  String? get groupId => group.value?.groupId;

  /// The active group being accessed
  final group = Rxn<GroupModel>();

  /// Fetch group information for the provided group id
  /// in the URL and make it the active group
  void _fetchActiveGroup() async {
    String? groupId = Get.parameters["groupId"];
    if (groupId == null) {
      return;
    }
    final group = await _api.getGroup(groupId: groupId);
    if (group == null) {
      // TODO: Handle what happens when a group was not found
    } else {
      this.group.value = group;
    }
  }

  void createGroup() async {
    final Response<GroupModel> response = await _api.createGroup(
      groupName: "Default",
    );
    // Finally
    if (response.statusCode == 200) {
      final String? newGroupId = response.body?.groupId;
      if (newGroupId == null) {
        // Should we do something in response to a missing group id?
        return;
      }
      Get.toNamed("/group/$newGroupId");
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Attempt to fetch the active group immediately
    _fetchActiveGroup();
  }

  @override
  void onReady() {
    super.onReady();
    // Listen for changes to the group ID URL parameter
    ever(Get.parameters.obs, (_) => _fetchActiveGroup());
  }
}

/// The parent page for attendance group pages which
/// handles navigation between them.
class GroupPage extends StatelessWidget {
  late final GroupController _controller = Get.put(GroupController());

  final RxInt _currentIndex = 1.obs;
  final RxBool isLoading = true.obs;

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

  late final List<Widget> _pages = [
    GroupAttendeesScreen(isLoading: isLoading),
    GroupHomeScreen(group: _controller.group, isLoading: isLoading),
    GroupAttendanceSessionScreen(group: _controller.group),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text("${_controller.group.value?.name ?? ''}"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: _pages,
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
