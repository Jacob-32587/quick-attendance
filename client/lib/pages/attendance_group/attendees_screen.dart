import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/public_user_model.dart';
import 'package:quick_attendance/pages/attendance_group/components/display_users.dart';
import 'package:quick_attendance/pages/attendance_group/components/group_page.dart';
import 'package:quick_attendance/pages/attendance_group/components/group_scroll_view.dart';

class GroupAttendeesScreen extends StatelessWidget {
  late final GroupController _controller = Get.find();
  late final ProfileController _profileController = Get.find();

  String? get currentUserId => _profileController.user.value?.userId.value;
  bool get isOwnerOrManager {
    return isManager || isOwner;
  }

  bool get isManager {
    final group = _controller.group.value;
    if (group == null || currentUserId == null) {
      return false;
    }
    if (group.managers?.any((user) => user.userId.value == currentUserId) ==
        true) {
      return true;
    }
    return false;
  }

  bool get isOwner {
    final group = _controller.group.value;
    if (group == null || currentUserId == null) {
      return false;
    }
    if (group.owner.value?.userId.value == currentUserId) {
      return true;
    }
    return false;
  }

  List<PublicUserModel> get allMembers {
    List<PublicUserModel> combined = [];

    final owner = _controller.group.value?.owner.value;
    if (owner != null) {
      combined.add(owner);
    }
    final managers = _controller.group.value?.managers;
    if (managers != null) {
      combined.addAll(managers);
    }
    final members = _controller.group.value?.members;
    if (members != null) {
      combined.addAll(members);
    }
    return combined;
  }

  GroupAttendeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupPageContainer(
      title: _controller.group.value?.name.value ?? "Unknown Group",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manage",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                label: Text(
                  "View Attendance Records",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                icon: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                ),
                onPressed: () {
                  // TODO: View Attendance Records
                },
              ),
              const SizedBox(width: 20),
              OutlinedButton.icon(
                label: Text(
                  "Invite User",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                icon: Icon(
                  Icons.person_add,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                ),
                onPressed: () {
                  // TODO: View Attendance Records
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          DisplayUsers(
            hasLoaded: _controller.hasLoadedGroup,
            isLoading: _controller.isLoadingGroup,
            emptyMessage: "There are no members in this group.",
            title: "Members",
            users: allMembers,
          ),
        ],
      ),
    );
  }
}
