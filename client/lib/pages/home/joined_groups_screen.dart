import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/group_header.dart';
import 'package:quick_attendance/pages/home/components/group_list.dart';
import 'package:quick_attendance/pages/home/components/has_floating_action_button.dart';
import 'package:quick_attendance/pages/home/components/join_group_popup.dart';

class JoinedGroupsScreen extends StatefulWidget
    implements HasFloatingActionButton {
  const JoinedGroupsScreen({super.key});

  @override
  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Todo add joined group
        showJoinGroupPopup(context);
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  State<StatefulWidget> createState() => _JoinedGroupsScreenState();
}

class _JoinedGroupsScreenState extends State<JoinedGroupsScreen> {
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
              "Joined Groups",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Manage the groups you attend",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            GroupHeader(
              title: "",
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.lightBlue),
                  onPressed: () {
                    // TODO: Handle joining a group with a screen for entering invite code.
                  },
                ),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      profileController.prefersListView.value
                          ? Icons.grid_view
                          : Icons.list,
                      color: Colors.lightBlue,
                    ),
                    onPressed: () {
                      profileController.setListViewPreference(
                        !profileController.prefersListView.value,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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
