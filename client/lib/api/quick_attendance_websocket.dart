import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/api/web_socket_service.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';

class QuickAttendanceWebsocket extends WebSocketService {
  late final QuickAttendanceApi _api = Get.find();
  late final AuthController _auth = Get.find();
  late final GroupController _groupController = Get.find();

  /// Define a custom handler for when the attendanceTaken event is received
  /// from the server.
  void Function()? attendanceTakenHandler;
  @override
  void registerListeners() {
    var socket = this.socket;
    if (socket == null) {
      return;
    }
    socket.on("attendanceTaken", (_) {
      var handler = attendanceTakenHandler;
      print("Attendance Taken");
      if (handler != null) {
        handler();
      }
    });
  }

  @override
  void onDisconnect() {
    _groupController.fetchGroup(_groupController.groupId);
    Get.snackbar(
      "Attendance",
      "Disconnected from attendance session",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.blue.shade50,
    );
  }

  @override
  void onConnect() {
    // TODO: implement onConnect
  }

  @override
  void onConnectFailure() {
    // TODO: implement onConnectFailure
  }

  void connectToGroupAttendance({required String? groupId}) {
    var domainAndPort = _api.domainAndPort.value;
    super.connectToServer(
      url: "ws://$domainAndPort",
      optionBuilder:
          (defaultOptions) => defaultOptions
              .setQuery({"group_id": groupId})
              .setAuth({"token": _auth.jwt.value}),
    );
  }
}
