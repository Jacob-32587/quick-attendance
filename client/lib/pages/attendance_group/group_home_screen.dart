import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/pages/attendance_group/attendees_screen.dart';
import 'package:quick_attendance/pages/attendance_group/components/group_scroll_view.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';

class GroupHomeScreen extends StatelessWidget {
  late final GroupController _controller = Get.find();

  GroupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoadingGroup.value ||
          (_controller.hasLoadedGroup.value &&
              _controller.group.value != null)) {
        return _GroupScreen(controller: _controller);
      } else {
        return _GroupNotFoundScreen();
      }
    });
  }
}

class _GroupScreen extends StatelessWidget {
  final GroupController controller;
  const _GroupScreen({required this.controller});
  @override
  Widget build(BuildContext context) {
    return GroupPageContainer(
      title: controller.group.value?.name.value ?? "Unknown Group",
      content: Obx(
        () => BinaryChoice(
          choice: controller.isEditingGroup.value,
          widget1: _GroupEditScreen(controller: controller),
          widget2: _GroupDetailsScreen(controller: controller),
        ),
      ),
    );
  }
}

class _GroupNotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Group does not exist",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Get.offNamed("/");
            },
            child: Text("Back to Home"),
          ),
        ],
      ),
    );
  }
}

class _GroupDetailsScreen extends StatelessWidget {
  final GroupController controller;

  _GroupDetailsScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonShimmer(
          isLoading: controller.isLoadingGroup,
          widget: Obx(
            () => Text(
              controller.group.value?.description.value ?? "",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        GroupAttendees(),
      ],
    );
  }
}

class _GroupEditScreen extends StatelessWidget {
  final GroupController controller;

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  _GroupEditScreen({required this.controller}) {
    nameController = TextEditingController(
      text: controller.group.value?.name.value,
    );
    descriptionController = TextEditingController(
      text: controller.group.value?.description.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonShimmer(
          isLoading: controller.isLoadingGroup,
          widget: TextField(
            controller: nameController,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: "Group Name",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(height: 8),
        SkeletonShimmer(
          isLoading: controller.isLoadingGroup,
          widget: TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Group Description",
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(height: 1000, width: 10),
      ],
    );
  }
}
