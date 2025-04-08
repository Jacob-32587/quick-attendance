import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/pages/attendance_group/attendance_session_screen.dart';
import 'package:quick_attendance/pages/attendance_group/attendees_screen.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';
import 'package:quick_attendance/pages/attendance_group/group_home_screen.dart';

/// The parent page for attendance group pages which
/// handles navigation between them.
class GroupPage extends UrlGroupPage {
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
  Widget buildWithController(BuildContext context, GroupController controller) {
    return Obx(
      () => Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: [
            GroupAttendeesScreen(),
            GroupHomeScreen(),
            GroupAttendanceSessionScreen(group: controller.group),
          ],
        ),
        bottomNavigationBar:
            controller.group.value == null
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
