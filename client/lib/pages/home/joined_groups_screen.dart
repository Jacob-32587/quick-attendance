import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/group_header.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/pending_invite_jwt_model.dart';
import 'package:quick_attendance/pages/home/components/async_icon_button.dart';
import 'package:quick_attendance/pages/home/components/display_groups.dart';

class JoinedGroupsScreen extends StatelessWidget {
  final ProfileController _profileController = Get.find();

  JoinedGroupsScreen({super.key});

  void navigateToGroup(String groupId) {
    Get.toNamed("/group/$groupId");
  }

  Future<void> onRefresh() async {
    _profileController.fetchGroups();
    _profileController.fetchProfileData();
  }

  String _getGroupInviteMessage(PendingInviteJwtModel jwtModel) {
    String uniqueIdMessage = "";
    if (jwtModel.uniqueIdSettings != null) {
      // Make if statements readable
      var minLength = jwtModel.uniqueIdSettings?.minLength;
      var maxLength = jwtModel.uniqueIdSettings?.maxLength;

      if (minLength != null && maxLength == null) {
        uniqueIdMessage +=
            ", a unique id of at least $minLength characters is required.";
      } else if (minLength == null && maxLength != null) {
        uniqueIdMessage += ", a unique id of at most $maxLength is required.";
      } else if (minLength != null && maxLength != null) {
        if (minLength == maxLength) {
          ", a unique id with $minLength characters is required";
        } else {
          uniqueIdMessage +=
              ", a unique id between $minLength and $maxLength characters is required";
        }
      }
    }
    return "${jwtModel.groupName} is inviting you as a ${jwtModel.isManagerInvite ? "manager" : "member"}$uniqueIdMessage";
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
            Text(
              "Attend Groups",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Here you can manage the groups you attend",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            DisplayGroups(
              title: "Joined Groups",
              isLoading: _profileController.isLoadingGroups,
              hasLoaded: _profileController.hasLoadedGroups,
              groups: _profileController.memberGroups,
              emptyMessage:
                  "You are not apart of any groups, accept an invite to join one!",
            ),
            const SizedBox(height: 36),
            ListHeader(title: "Group Invites", children: []),
            const SizedBox(height: 12),
            Obx(() {
              final jwtModel = _profileController.pendingGroupJwts;
              if (jwtModel == null || jwtModel.isEmpty) {
                return Text(
                  "No pending invites",
                  style: TextStyle(color: Colors.grey),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...jwtModel.map((jwtModel) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    jwtModel.groupName,
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (jwtModel.uniqueIdSettings != null)
                                    Text(
                                      "This group requires a unique ID",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              spacing: 16,
                              children: [
                                AsyncIconButton(
                                  onPressed: () async {
                                    await _profileController.respondToInvite(
                                      groupInviteJwt: jwtModel.jwt,
                                      uniqueId: null,
                                      accept: true,
                                    );
                                  },
                                  icon: Icons.check,
                                  iconColor: Colors.green.shade800,
                                  backgroundColor: Colors.green.shade100,
                                ),
                                AsyncIconButton(
                                  onPressed: () async {
                                    await _profileController.respondToInvite(
                                      groupInviteJwt: jwtModel.jwt,
                                      uniqueId: null,
                                      accept: false,
                                    );
                                  },
                                  icon: Icons.close,
                                  iconColor: Colors.red.shade800,
                                  backgroundColor: Colors.red.shade100,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
