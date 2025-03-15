import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/group_list.dart';
import 'package:quick_attendance/pages/home/components/has_floating_action_button.dart';

class ManagedGroupsScreen extends StatelessWidget
    implements HasFloatingActionButton {
  final ProfileController _profileController = Get.find();

  ManagedGroupsScreen({super.key});

  Future<void> onRefresh() async {
    _profileController.fetchGroups();
  }

  @override
  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _profileController.createGroup();
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        // Enables scroll down to refresh
        onRefresh: onRefresh,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            // Greeting to the user
            Text(
              "Managed Groups",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Take attendance for any group you manage",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            // Display the groups the user manages
            Obx(
              () => GroupList(
                groups: _profileController.ownedGroups,
                isListView: _profileController.prefersListView,
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
