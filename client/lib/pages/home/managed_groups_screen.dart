import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/create_group_popup.dart';
import 'package:quick_attendance/pages/home/components/display_groups.dart';
import 'package:quick_attendance/pages/home/components/has_floating_action_button.dart';

class ManagedGroupsScreen extends StatelessWidget
    implements HasFloatingActionButton {
  final ProfileController _profileController = Get.find();

  bool get hasAnyManagedGroups =>
      _profileController.managedGroups?.isEmpty == false;

  bool get hasAnyOwnedGroups =>
      _profileController.ownedGroups?.isEmpty == false;

  ManagedGroupsScreen({super.key});

  Future<void> onRefresh() async {
    _profileController.fetchGroups();
  }

  @override
  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showCreateGroupPopup(context);
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
            DisplayGroups(
              title: "Owned Groups",
              isLoading: _profileController.isLoadingGroups,
              hasLoaded: _profileController.hasLoadedGroups,
              emptyMessage: "You do not own any groups yet.",
              groups: _profileController.ownedGroups,
            ),
            SizedBox(height: 48),
            DisplayGroups(
              title: "Groups you manage",
              isLoading: _profileController.isLoadingGroups,
              hasLoaded: _profileController.hasLoadedGroups,
              emptyMessage: "You are not a manager of any group yet.",
              groups: _profileController.managedGroups,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
