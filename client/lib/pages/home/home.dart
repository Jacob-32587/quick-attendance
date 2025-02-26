import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/pages/home/components/has_floating_action_button.dart';
import 'package:quick_attendance/pages/home/history_screen.dart';
import 'package:quick_attendance/pages/home/home_screen.dart';
import 'package:quick_attendance/pages/home/joined_groups_screen.dart';
import 'package:quick_attendance/pages/home/managed_groups_screen.dart';
import 'package:quick_attendance/pages/home/profile_screen.dart';

class HomeController extends GetxController {
  // Start the user on the home page
  var currentIndex = 2.obs;
  PageController pageController = PageController(initialPage: 2);

  void changePage(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  final String title = "Quick Attendance";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;
  final HomeController controller = Get.put(HomeController());

  final List<Widget> _pages = [
    HistoryScreen(),
    JoinedGroupsScreen(),
    HomeScreen(),
    ManagedGroupsScreen(),
    ProfileScreen(),
  ];

  void _incrementCounter() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    return Obx(
      () => Scaffold(
        body: PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          children: _pages,
        ),
        floatingActionButton:
            _pages[controller.currentIndex.value] is HasFloatingActionButton
                ? (_pages[controller.currentIndex.value]
                        as HasFloatingActionButton)
                    .buildFAB()
                : null,
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
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
                icon: const Icon(Icons.group),
                label: "Manage",
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today_rounded),
                label: "Attend",
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
