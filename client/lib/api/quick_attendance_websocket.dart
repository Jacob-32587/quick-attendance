import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/api/web_socket_service.dart';

class QuickAttendanceWebsocket extends WebSocketService {
  late final QuickAttendanceApi _api = Get.find();
  @override
  void registerListeners() {}
  @override
  void connectToServer({String? url}) {
    var baseUrl = url ?? _api.apiClient.baseUrl;
    super.connectToServer(url: "${baseUrl}/");
  }
}
