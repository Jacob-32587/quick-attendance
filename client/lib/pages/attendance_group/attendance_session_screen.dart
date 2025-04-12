import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/info_card.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/pages/attendance_group/components/qr-code-view.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';

class GroupAttendanceSessionController extends GetxController {
  late final GroupController _groupController = Get.find();
  late final ProfileController _profileController = Get.find();

  /// Loading state
  final RxBool isStartingSession = false.obs;

  /// Loading state
  final RxBool isEndingSession = false.obs;

  String? get activeSessionId =>
      _groupController.group.value?.currentAttendanceId.value;

  Future<void> onRefresh() async {
    await _groupController.fetchGroup(_groupController.groupId);
  }
}

/// Handles joining and managing the group's attendance session
class GroupAttendanceSessionScreen extends StatelessWidget {
  late final GroupAttendanceSessionController _controller = Get.put(
    GroupAttendanceSessionController(),
  );
  final Rxn<GroupModel> group;
  GroupAttendanceSessionScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _controller.onRefresh,
        child: ListView(
          // forces the layout to be scrollable even if there isn't enough content to do so
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(8),
          children: [
            Text(
              "Attend",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SkeletonShimmer(
              isLoading: _controller._groupController.isLoadingGroup,
              skeletonHeight: 40,
              widget: InfoCard(
                child: Obx(() {
                  final activeSessionId = _controller.activeSessionId;
                  if (activeSessionId == null) {
                    return Text("No active session");
                  } else {
                    return Text("There is an active session!");
                  }
                }),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final userId = _controller._profileController.userId;
              if (userId == null) {
                return SizedBox.shrink();
              }
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 8,
                      child: QrCodeView(
                        code: userId,
                        size: MediaQuery.of(context).size.width * 0.5,
                      ),
                    ),
                    Text(
                      "Waiting for connection",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
            Obx(
              () => PrimaryButton(
                text: "Start Session",
                isLoading: _controller.isStartingSession.value,
                onPressed: _controller.onRefresh,
              ),
            ),
            Obx(() {
              final activeSessionId = _controller.activeSessionId;
              if (activeSessionId == null) {
                return SizedBox.shrink();
              } else {
                return PrimaryButton(
                  text: "End Attendance",
                  isLoading: _controller.isEndingSession.value,
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
