import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/models/group_model.dart';

class GroupHomeScreen extends StatelessWidget {
  final Rxn<GroupModel> group;
  final bool isLoading;
  final bool hasLoaded;

  const GroupHomeScreen({
    super.key,
    required this.group,
    required this.isLoading,
    required this.hasLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        GroupModel? val = group.value;
        if (hasLoaded && val == null) {
          return _GroupNotFoundScreen();
        } else {
          return _GroupDetailsScreen(group: val, isLoading: isLoading);
        }
      }),
    );
  }
}

class _GroupNotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Group does not exist",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Get.offNamed("/home");
          },
          child: Text("Back to Home"),
        ),
      ],
    );
  }
}

class _GroupDetailsScreen extends StatelessWidget {
  final GroupModel? group;
  final bool isLoading;

  const _GroupDetailsScreen({required this.group, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            // Group Name
            () => SkeletonShimmer(
              isLoading: isLoading,
              widget: Text(
                group?.name.value ?? "",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 8),

          Obx(
            // Group Description
            () => Text(
              group?.description.value ?? "",
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 16),
          // TODO: Display attendance records of this group for this user
        ],
      ),
    );
  }
}
