import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/display_groups.dart';

class JoinedGroupsScreen extends StatelessWidget {
  final ProfileController _profileController = Get.find();

  JoinedGroupsScreen({super.key});

  void navigateToGroup(String groupId) {
    Get.toNamed("/group/$groupId");
  }

  Future<void> onRefresh() async {
    _profileController.fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            // Greeting to the user
            Text(
              "Joined Groups",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Manage the groups you attend",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            DisplayGroups(
              isLoading: _profileController.isLoadingGroups,
              hasLoaded: _profileController.hasLoadedGroups,
              groups: _profileController.memberGroups,
              emptyMessage:
                  "You are not apart of any groups. Click the + button to join one.",
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
