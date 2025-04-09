import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/group_header.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer_list.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/public_user_model.dart';
import 'package:quick_attendance/pages/attendance_group/components/user_list.dart';

class DisplayUsers extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final RxBool isLoading;
  final RxBool hasLoaded;

  /// Determines whether or not to show a shimmer on the title.
  /// Useful if you are displaying information in the title that is loaded in.
  final bool displayLoadingTitle;
  final List<PublicUserModel>? users;

  /// Decides whether or not to add a tag saying they attended
  final bool displayAttended;

  const DisplayUsers({
    super.key,
    this.title = "",
    this.emptyMessage = "",
    this.users,
    required this.isLoading,
    required this.hasLoaded,
    this.displayAttended = false,
    this.displayLoadingTitle = false,
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
          isLoading: displayLoadingTitle ? isLoading : null,
          children: [],
        ),
        Obx(() {
          if (isLoading.value == false &&
              hasLoaded.value &&
              hasAnyUsers == false) {
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
        SkeletonShimmerList(
          isLoading: isLoading,
          isListView: true,
          widget: UserList(users: users, isListView: true),
        ),
      ],
    );
  }
}
