import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/models/attendance_history_model.dart';

class HistoryController extends GetxController {
  late final QuickAttendanceApi _api = Get.find();
  late final AuthController authController = Get.find();
  var jwt = Rxn<String>();
  final attendanceHistory = Rxn<AttendanceHistoryModel>();

  /// Loading state for fetching group list information
  final RxBool isLoadingHistory = false.obs;
  final RxBool hasLoadedHistory = false.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  /// Get the groups the user owns, manages, or has joined from the server
  Future<void> getAttendanceHistoryForWeek() async {
    isLoadingHistory.value = true;
    final response = await _api.getWeeklyUserAttendance();
    if (response.statusCode == HttpStatusCode.ok) {
      hasLoadedHistory.value = true;
      attendanceHistory.value = response.body;
    } else {
      // TODO: What should we do when this request fails
    }
    isLoadingHistory.value = false;
  }
}
