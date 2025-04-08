import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_websocket.dart';
import 'package:quick_attendance/api/web_socket_service.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';
import 'package:quick_attendance/pages/auth/auth_gate.dart';

class AttendGroupAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGate(page: AttendGroupPage());
  }
}

class AttendGroupPage extends UrlGroupPage {
  final QuickAttendanceWebsocket _webSocketService = Get.find();
  @override
  Widget buildWithController(BuildContext context, GroupController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ever(controller.hasLoadedGroup, (group) {
        if (group && controller.group.value != null) {
          _webSocketService.connectToServer()
        }
      });
    })
    return Obx(
      () => BinaryChoice(
        choice: controller.isLoadingGroup.value,
        widget1: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 32),
                Text(
                  "Retrieving Group Information...",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
