import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/models/attendance_history_model.dart';
import 'package:quick_attendance/util/time.dart';

class AttendanceEventData {
  late String attendanceId;
  late String groupId;
  AttendanceEventData({required String attendanceId, required String groupId}) {
    this.attendanceId = attendanceId;
    this.groupId = groupId;
  }

  String getEventId() {
    return attendanceId + groupId;
  }
}

class HistoryController extends GetxController {
  late final QuickAttendanceApi _api = Get.find();
  late final AuthController authController = Get.find();
  final calendarEventController = EventController<AttendanceEventData?>();
  final attendanceHistory = Rxn<AttendanceHistoryModel>();
  final clearedData = RxBool(false);
  final currentDate = Rx<DateTime>(DateTime.now());

  /// Loading state for fetching group list information
  final RxBool isLoadingHistory = false.obs;
  final RxBool hasLoadedHistory = false.obs;

  @override
  void onInit() {
    ever(authController.isLoggedIn, (loggedIn) {
      if (loggedIn) {
        onRefresh();
      } else {
        calendarEventController.removeWhere((x) => true);
      }
    });
    super.onInit();
  }

  /// Get the groups the user owns, manages, or has joined from the server
  Future<void> getAttendanceHistoryForWeek(DateTime? time) async {
    isLoadingHistory.value = true;
    final response = await _api.getWeeklyUserAttendance(
      time?.year,
      time?.month,
      getWeekOfMonthNullable(time),
    );
    if (response.statusCode == HttpStatusCode.ok) {
      attendanceHistory.value = response.body;
    } else {
      // TODO: What should we do when this request fails
    }
    isLoadingHistory.value = false;
  }

  Future<void> onRefresh() async {
    await getAttendanceHistoryForWeek(currentDate.value);
    var events =
        attendanceHistory.value?.attendance
            .map(
              (x) => x.attendanceRecords.map(
                (y) => _getCalendarEventData(
                  x.groupName.value,
                  x.groupId.value,
                  y.attendanceStartTime.value,
                  y.attendanceEndTime.value,
                  y.attendanceId.value,
                  y.present.value,
                ),
              ),
            )
            .expand((e) => e)
            .nonNulls
            .toList() ??
        [];

    var storedEventsIds =
        calendarEventController.allEvents
            .map((x) => x.event?.getEventId())
            .nonNulls
            .toSet();

    var newEvents =
        events
            .where((x) => !storedEventsIds.contains(x.event?.getEventId()))
            .toList();

    if (newEvents.isEmpty) {
      return;
    }
    calendarEventController.addAll(newEvents);
  }

  CalendarEventData<AttendanceEventData>? _getCalendarEventData(
    String? groupName,
    String? groupId,
    DateTime? attendanceStartTime,
    DateTime? attendanceEndTime,
    String? attendanceId,
    bool? present,
  ) {
    if (groupName != null &&
        attendanceStartTime != null &&
        attendanceEndTime != null &&
        groupId != null &&
        attendanceId != null &&
        present != null) {
      if (attendanceStartTime.toLocal().day ==
          attendanceEndTime.toLocal().day) {
        return CalendarEventData<AttendanceEventData>(
          title: groupName,
          date: attendanceStartTime.toLocal(),
          endDate: attendanceEndTime.toLocal().add(const Duration(minutes: 10)),
          startTime: attendanceStartTime.toLocal(),
          endTime: attendanceEndTime.toLocal().add(const Duration(minutes: 10)),
          color: present ? Colors.blue : Colors.red,
          event: AttendanceEventData(
            attendanceId: attendanceId,
            groupId: groupId,
          ),
        );
      }
    }
    return null;
  }
}
