import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/group_list.dart';
import 'package:quick_attendance/pages/home/components/has_floating_action_button.dart';

class ManagedGroupsScreen extends StatefulWidget
    implements HasFloatingActionButton {
  const ManagedGroupsScreen({super.key});

  @override
  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Todo add managed group
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  State<StatefulWidget> createState() => _ManagedGroupsScreenState();
}

class _ManagedGroupsScreenState extends State<ManagedGroupsScreen> {
  final ProfileController profileController = Get.find();
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
            // Display the groups the user is in
            Obx(
              () => GroupList(
                groups: profileController.joinedGroups,
                isListView: profileController.prefersListView.value,
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
