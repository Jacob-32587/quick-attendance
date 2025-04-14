import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/api/quick_attendance_websocket.dart';
import 'package:quick_attendance/api/web_socket_service.dart';
import 'package:quick_attendance/components/animated_check.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/flat_button.dart';
import 'package:quick_attendance/components/info_card.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/components/success_card.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/pages/attendance_group/camera_page.dart';
import 'package:quick_attendance/pages/attendance_group/components/glowing_card.dart';
import 'package:quick_attendance/pages/attendance_group/components/qr-code-view.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';
import 'package:vibration/vibration.dart';

class GroupAttendanceSessionController extends GetxController {
  late final GroupController _groupController = Get.find();
  late final ProfileController _profileController = Get.find();
  late final QuickAttendanceApi _api = Get.find();
  late final QuickAttendanceWebsocket _websocketService = Get.find();

  /// Loading state
  final RxBool isStartingSession = false.obs;

  /// Loading state
  final RxBool isEndingSession = false.obs;

  /// Page state for when attendance has been taken
  final RxBool showAttendanceTaken = false.obs;

  /// Page state which allows MANAGERS to automatically become attended after a delay
  /// This was really only added for debug purposes, but may be used for the demo.
  final RxBool bypassAttendance = false.obs;

  // User types
  bool get isOwner => _groupController.isOwner;
  bool get isManager => _groupController.isManager;
  bool get isOwnerOrManager => _groupController.isOwnerOrManager;

  // Socket state
  bool get isConnectedToSession =>
      _websocketService.socketConnectionState.value ==
      SocketConnectionState.connected;
  bool get failedToConnect =>
      _websocketService.socketConnectionState.value ==
      SocketConnectionState.failedToConnect;
  bool get isConnecting =>
      _websocketService.socketConnectionState.value ==
      SocketConnectionState.isConnecting;

  String? get activeSessionId =>
      _groupController.group.value?.currentAttendanceId.value;

  Future<void> onRefresh() async {
    await _groupController.fetchGroup(_groupController.groupId);
  }

  Future<void> startAttendance() async {
    final String? groupId = _groupController.groupId;
    if (groupId == null) {
      return;
    }
    isStartingSession.value = true;
    ApiResponse<Null> response = await _api.startAttendanceSession(groupId);
    if (response.statusCode == HttpStatusCode.ok) {
      await onRefresh(); // Reload the group to update reactive UI
      if (activeSessionId != null) {
        Get.snackbar(
          "Success",
          "You started a new attendance session!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade800,
          colorText: Colors.green.shade50,
        );
      }
    } else {
      Get.snackbar(
        "Failed",
        "The server could not start an attendance session. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isStartingSession.value = false;
  }

  Future<void> joinAttendance() async {
    String? groupId = _groupController.groupId;
    if (groupId == null) {
      return; // this should never happen
    }
    _websocketService.connectToGroupAttendance(groupId: groupId);
    if (bypassAttendance.value) {
      await Future.delayed(Duration(seconds: 3));
      _api.putAttendedUsers(groupId, [_profileController.userId!]);
    }
  }

  Future<void> endAttendance() async {
    var group = _groupController.group.value;
    if (group == null || _groupController.currentAttendanceId == null) {
      return; // There is no attendance to stop
    }
    isEndingSession.value = true;
    group.currentAttendanceId.value = null;
    ApiResponse<Null> response = await _api.updateGroup(group);
    if (response.statusCode == HttpStatusCode.ok) {
      Get.snackbar(
        "Success",
        "Ended attendance session successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.green.shade50,
      );
    }
    isEndingSession.value = false;
  }

  void leaveAttendanceSession() {
    showAttendanceTaken.value = false;
    _websocketService.disconnect();
  }

  void attendanceTakenHandler() async {
    showAttendanceTaken.value = true;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 300);
    }
  }

  /// Handles what happens when the user presses "take attendance"
  void onTakeAttendance() {
    Get.to(
      () => CameraPage(groupId: _groupController.groupId),
      fullscreenDialog: true,
    );
  }

  @override
  void onInit() {
    _websocketService.attendanceTakenHandler = attendanceTakenHandler;
    super.onInit();
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
    double qrSize = MediaQuery.of(context).size.width * 0.8;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _controller.onRefresh,
        child: ListView(
          // forces the layout to be scrollable even if there isn't enough content to do so
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(8),
          children: [
            SkeletonShimmer(
              isLoading: _controller._groupController.isLoadingGroup,
              skeletonHeight: 40,
              widget: Obx(() {
                final activeSessionId = _controller.activeSessionId;
                final isOwner = _controller.isOwner;
                if (isOwner) {
                  // Owners can't connect to the group's session
                  return SizedBox.shrink();
                }
                if (activeSessionId == null) {
                  return InfoCard(
                    child: Text("No active session. Swipe down to refresh."),
                  );
                } else if (_controller.isConnectedToSession == false) {
                  return SuccessCard(
                    child: Text(
                      "This group is currently taking attendance, join now!",
                    ),
                  );
                } else {
                  return InfoCard(
                    child: Text("You are connected to the session"),
                  );
                }
              }),
            ),
            const SizedBox(height: 16),
            QrAttendanceView(qrSize: qrSize),
            const SizedBox(height: 32),
            Divider(color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Obx(() {
                  if (_controller.isConnectedToSession) {
                    return FlatButton(
                      onPressed: _controller.leaveAttendanceSession,
                      child: Text("Disconnect"),
                    );
                  } else {
                    return FlatButton(
                      onPressed: _controller.joinAttendance,
                      child: Text("Join Attendance"),
                    );
                  }
                }),
                Obx(
                  () => BinaryChoice(
                    choice:
                        _controller.isOwnerOrManager &&
                        _controller.activeSessionId != null,
                    widget1: FlatButton(
                      onPressed: _controller.onTakeAttendance,
                      text: "Take Attendance",
                    ),
                  ),
                ),
                Obx(() {
                  final activeSessionId = _controller.activeSessionId;
                  if (activeSessionId == null) {
                    return FlatButton(
                      onPressed: _controller.startAttendance,
                      text: "Start Attendance",
                      isLoading: _controller.isStartingSession.value,
                    );
                  } else {
                    return FlatButton(
                      onPressed: _controller.endAttendance,
                      text: "End Attendance Session",
                      isLoading: _controller.isEndingSession.value,
                    );
                  }
                }),
                Obx(
                  () => BinaryChoice(
                    choice: _controller.isManager,
                    widget1: Obx(
                      () => FlatButton(
                        text:
                            _controller.bypassAttendance.value
                                ? "Disable Attendance Bypass"
                                : "Enable Attendance Bypass",
                        onPressed: _controller.bypassAttendance.toggle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QrAttendanceView extends StatelessWidget {
  final GroupAttendanceSessionController _controller = Get.find();

  final double qrSize;

  QrAttendanceView({required this.qrSize});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          children: [
            Obx(() {
              final userId = _controller._profileController.userId;
              if (userId == null) {
                return SizedBox.shrink(); // This should never happen
              }
              // Display the QR code, centered, with rounded corners.
              return Center(
                child: Card(
                  elevation: 8,
                  child:
                      _controller.isConnectedToSession
                          ? AnimatedGlowBox(
                            child: QrCodeView(code: userId, size: qrSize),
                          )
                          : Container(
                            height: qrSize,
                            width: qrSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                ),
              );
            }),

            // Black transparent blurred background
            Obx(
              () => BinaryChoice(
                choice: _controller.showAttendanceTaken.value,
                widget1: Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(color: Colors.black.withAlpha(50)),
                    ),
                  ),
                ),
              ),
            ),

            // Display disconnect option and green checkmark when attended
            Obx(
              () => BinaryChoice(
                choice: _controller.showAttendanceTaken.value,
                widget1: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AnimatedCheck(),
                        const SizedBox(height: 16),
                        Text(
                          "You have been marked as attended!",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: "Disconnect",
                          onPressed: _controller.leaveAttendanceSession,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          String status = "Waiting for connection";
          if (_controller.isConnecting) {
            status = "Connecting...";
          } else if (_controller.isConnectedToSession &&
              _controller.showAttendanceTaken.value == false) {
            status = "Waiting to be scanned...";
          } else {
            status = "You have been marked as attended!";
          }
          return Text(
            status,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          );
        }),
      ],
    );
  }
}
