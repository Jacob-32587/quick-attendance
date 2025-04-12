import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/api/web_socket_service.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

class QuickAttendanceWebsocket extends WebSocketService {
  late final QuickAttendanceApi _api = Get.find();
  late final AuthController _auth = Get.find();

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
      if (handler != null) {
        handler();
      }
    });
  }

  void connectToGroupAttendance({
    required String? groupId,
    void Function()? onConnect,
    void Function()? onConnectError,
    void Function()? onDisconnect,
  }) {
    var domainAndPort = _api.domainAndPort.value;
    super.connectToServer(
      url: "ws://$domainAndPort",
      optionBuilder:
          (defaultOptions) => defaultOptions
              .setQuery({"group_id": groupId})
              .setAuth({"token": _auth.jwt.value}),
      onConnect: onConnect,
      onConnectError: onConnectError,
      onDisconnect: onDisconnect,
    );
  }
}
