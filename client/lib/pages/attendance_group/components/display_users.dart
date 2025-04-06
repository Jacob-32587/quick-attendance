import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/group_header.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer_list.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/public_user_model.dart';
import 'package:quick_attendance/pages/attendance_group/components/user_list.dart';

class DisplayUsers extends StatelessWidget {
  late final ProfileController _profileController = Get.find();
  final String title;
  final String emptyMessage;
  final RxBool isLoading;
  final RxBool hasLoaded;
  final List<PublicUserModel>? users;

  DisplayUsers({
    super.key,
    this.title = "",
    this.emptyMessage = "",
    this.users,
    required this.isLoading,
    required this.hasLoaded,
  });

  bool get hasAnyUsers => users?.isEmpty == false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListHeader(
          title: title,
          children: [
            BinaryChoice(
              choice: hasAnyUsers,
              widget1: Obx(
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
              ),
            ),
          ],
        ),
        Obx(() {
          if (hasLoaded.value && hasAnyUsers == false) {
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
            isLoading: isLoading,
            isListView: _profileController.prefersListView,
            widget: UserList(
              users: users,
              isListView: _profileController.prefersListView,
            ),
          ),
        ),
      ],
    );
  }
}
