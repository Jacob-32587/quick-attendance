import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer_list.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/models/user_type.dart';
import 'package:quick_attendance/pages/home/components/group_header.dart';
import 'package:quick_attendance/pages/home/components/group_list.dart';

/// Widget that combines several components to handle the rendering of groups,
/// loading state, and the user's list view preference.
class DisplayGroups extends StatelessWidget {
  late final ProfileController _profileController = Get.find();
  final RxBool isLoading;
  final RxBool hasLoaded;
  final String title;
  final String emptyMessage;
  final RxList<GroupModel>? groups;
  final UserType userType;

  DisplayGroups({
    super.key,
    required this.isLoading,
    required this.hasLoaded,
    this.title = "",
    required this.groups,
    required this.emptyMessage,

    /// Required for navigating to a group. See Group GET request for details.
    required this.userType,
  });

  bool get hasAnyGroups => groups?.isEmpty == false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupHeader(
          title: title,
          children: [
            // Only display the list view preference button if there are groups
            hasAnyGroups
                ? Obx(
                  () => IconButton(
                    icon: Icon(
                      _profileController.prefersListView
                          ? Icons.grid_view
                          : Icons.list,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      _profileController.prefersListView =
                          !_profileController.prefersListView;
                    },
                  ),
                )
                : SizedBox.shrink(),
          ],
        ),
        Obx(() {
          if (_profileController.hasLoadedGroups.value &&
              hasAnyGroups == false) {
            return Text(
              emptyMessage,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          }
          return SizedBox.shrink();
        }),
        Obx(
          () => SkeletonShimmerList(
            isLoading: isLoading.value,
            isListView: _profileController.prefersListView,
            widget: GroupList(
              groups: groups,
              userType: userType,
              isListView: _profileController.prefersListView,
            ),
          ),
        ),
      ],
    );
  }
}
