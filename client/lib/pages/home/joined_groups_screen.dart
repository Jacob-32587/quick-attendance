import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer_list.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/home/components/group_header.dart';
import 'package:quick_attendance/pages/home/components/group_list.dart';
import 'package:quick_attendance/pages/home/components/has_floating_action_button.dart';
import 'package:quick_attendance/pages/home/components/join_group_popup.dart';

class JoinedGroupsScreen extends StatelessWidget
    implements HasFloatingActionButton {
  final ProfileController _profileController = Get.find();

  JoinedGroupsScreen({super.key});

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
            GroupHeader(
              title: "",
              children: [
                Obx(
                  () => IconButton(
                    icon: Icon(
                      _profileController.prefersListView
                          ? Icons.grid_view
                          : Icons.list,
                      color: Colors.lightBlue,
                    ),
                    onPressed: () {
                      _profileController.prefersListView =
                          !_profileController.prefersListView;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Obx(
              () => SkeletonShimmerList(
                isLoading: _profileController.isLoadingGroups.value,
                isListView: _profileController.prefersListView,
                widget: GroupList(
                  groups: _profileController.memberGroups,
                  isListView: _profileController.prefersListView,
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
