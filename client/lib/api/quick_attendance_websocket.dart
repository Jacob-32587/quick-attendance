import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/api/web_socket_service.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

class QuickAttendanceWebsocket extends WebSocketService {
  late final QuickAttendanceApi _api = Get.find();
  late final AuthController _auth = Get.find();
  @override
  void registerListeners() {}

  void connectToGroupAttendance({required String? groupId}) {
    var domainAndPort = _api.domainAndPort.value;
    super.connectToServer(
      url: "ws://$domainAndPort",
      optionBuilder:
          (defaultOptions) => defaultOptions
              .setQuery({"group_id": groupId})
              .setAuth({"token": _auth.jwt}),
    );
  }
}
