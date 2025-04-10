import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:quick_attendance/controllers/home_controller.dart';
import 'package:quick_attendance/pages/auth/auth_gate.dart';
import 'package:quick_attendance/pages/home/components/has_floating_action_button.dart';
import 'package:quick_attendance/pages/home/history_screen.dart';
import 'package:quick_attendance/pages/home/home_screen.dart';
import 'package:quick_attendance/pages/home/joined_groups_screen.dart';
import 'package:quick_attendance/pages/home/managed_groups_screen.dart';
import 'package:quick_attendance/pages/home/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  final String title = "Quick Attendance";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController controller = Get.find();

  late final PageController pageController = PageController(
    initialPage: controller.currentIndex.value,
  );

  void changePage(int index) {
    controller.currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    controller.currentIndex.value = index;
  }

  final List<Widget> _pages = [
    CalendarControllerProvider(controller: Get.find(), child: HistoryScreen()),
    JoinedGroupsScreen(),
    HomeScreen(),
    ManagedGroupsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      page: Obx(
        () => Scaffold(
          body: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: _pages,
          ),
          floatingActionButton:
              _pages[controller.currentIndex.value] is HasFloatingActionButton
                  ? (_pages[controller.currentIndex.value]
                          as HasFloatingActionButton)
                      .buildFAB(context)
                  : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: changePage,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface,
            enableFeedback: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: "History",
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today_rounded),
                label: "Attend",
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.group),
                label: "Manage",
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
