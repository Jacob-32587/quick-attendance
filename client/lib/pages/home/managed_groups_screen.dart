import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/group_list.dart';
import 'package:quick_attendance/pages/home/components/has_floating_action_button.dart';

class ManagedGroupsScreen extends StatelessWidget
    implements HasFloatingActionButton {
  final ProfileController profileController = Get.find();

  ManagedGroupsScreen({super.key});

  @override
  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        profileController.createGroup();
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                groups: profileController.managedGroups,
                isListView: profileController.prefersListView,
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
