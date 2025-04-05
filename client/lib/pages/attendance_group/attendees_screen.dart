import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/pages/attendance_group/components/group_scroll_view.dart';
import 'package:quick_attendance/pages/attendance_group/group_page.dart';

class GroupAttendeesScreen extends StatelessWidget {
  late final GroupController _controller = Get.find();
  GroupAttendeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupPageContainer(
      title: _controller.group.value?.name.value ?? "Unknown Group",
      content: Column(
        children: [
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
          Text("Test"),
        ],
      ),
    );
  }
}
