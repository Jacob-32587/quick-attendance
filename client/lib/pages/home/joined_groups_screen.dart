import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/pending_invite_jwt_model.dart';
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

  bool uniqueIdRequired(PendingInviteJwtModel jwtModel) {
    if (jwtModel.uniqueIdSettings != null) {
      if ((jwtModel.uniqueIdSettings?.requiredForManager ?? false) &&
          jwtModel.isManagerInvite) {
        return true;
      }
      return true;
    }
    return false;
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
                  "You are not apart of any groups, accept an invite to join one!",
            ),
            SizedBox(height: 24),

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
                  Text(
                    "Accept or Deny Group Invites",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
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
                              child: Text(
                                _getGroupInviteMessage(jwtModel),
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    if (uniqueIdRequired(jwtModel)) {
                                      final TextEditingController
                                      _uniqueIdController =
                                          TextEditingController();
                                      final result = await showDialog<String?>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Enter Unique ID'),
                                            content: TextField(
                                              controller: _uniqueIdController,
                                              decoration: InputDecoration(
                                                hintText: 'Unique ID',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(null),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                    _uniqueIdController.text
                                                        .trim(),
                                                  );
                                                },
                                                child: Text('Submit'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (result != null && result.isNotEmpty) {
                                        await _profileController
                                            .respondToInvite(
                                              groupInviteJwt: jwtModel.jwt,
                                              uniqueId: result,
                                              accept: true,
                                            );
                                      }
                                    } else {
                                      await _profileController.respondToInvite(
                                        groupInviteJwt: jwtModel.jwt,
                                        uniqueId: null,
                                        accept: true,
                                      );
                                    }
                                  },
                                  child: Text("Accept"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                ),

                                TextButton(
                                  onPressed: () async {
                                    await _profileController.respondToInvite(
                                      groupInviteJwt: jwtModel.jwt,
                                      uniqueId: null,
                                      accept: false,
                                    );
                                  },
                                  child: Text("Deny"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
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
