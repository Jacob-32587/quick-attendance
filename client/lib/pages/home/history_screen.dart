import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/controllers/history_controller.dart';
import 'package:intl/intl.dart';
import 'package:quick_attendance/models/attendance_history_model.dart';
import 'package:quick_attendance/util/time.dart';

class _AttendanceEventData {
  late String attendanceId;
  late String groupId;
  _AttendanceEventData({
    required String attendanceId,
    required String groupId,
  }) {
    this.attendanceId = attendanceId;
    this.groupId = groupId;
  }

  String getEventId() {
    return attendanceId + groupId;
  }

  static _AttendanceEventData? castObj(Object? obj) {
    if (obj == _AttendanceEventData) {
      return obj as _AttendanceEventData;
    }
    return null;
  }
}

class HistoryScreen extends StatelessWidget {
  late final HistoryController _historyController = Get.find();
  final EventController _calendarEventController = EventController();
  final clearedData = RxBool(false);
  final currentTime = Rx<DateTime>(DateTime.now());

  late final QuickAttendanceApi _api = Get.find();
  final attendanceHistory = Rxn<AttendanceHistoryModel>();

  HistoryScreen({super.key});

  Future<void> getAttendanceHistoryForWeek(DateTime? time) async {
    // isLoadingHistory.value = true;
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
    // isLoadingHistory.value = false;
  }

  Future<void> onRefresh() async {
    await _historyController.getAttendanceHistoryForWeek(currentTime.value);
    var events =
        _historyController.attendanceHistory.value?.attendance
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

    // _calendarEventController.updateCalendarData((z) {
    //   var storedEventsIds = z.dayEvents.values
    //       .expand((e) => e)
    //       .map((x) => _AttendanceEventData.castObj(x.data)?.getEventId());

    // var newEvents =
    //     events
    //         .where(
    //           (x) =>
    //               !storedEventsIds.contains(
    //                 _AttendanceEventData.castObj(x.data)?.getEventId(),
    //               ),
    //         )
    //         .toList();

    // if (newEvents.isEmpty) {
    //   return;
    // }
    // return z.addEvents(newEvents);
    // });
  }

  CalendarEventData? _getCalendarEventData(
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
      return CalendarEventData(
        title: groupName,
        date: attendanceStartTime.toLocal(),
        startTime: attendanceStartTime.toLocal(),
        endTime: attendanceEndTime.toLocal(),
        color: present ? Colors.blue : Colors.red,
        event: _AttendanceEventData(
          attendanceId: attendanceId,
          groupId: groupId,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // _calendarEventController.updateCalendarData((x) {
    //   x.clearAll();
    //   onRefresh();
    // });
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scaffold(
        appBar: AppBar(title: Text("Attendance Calendar")),
        body: SafeArea(
          child: DayView(
            controller: _calendarEventController,
            heightPerMinute: 0.9,
            // onAutomaticAdjustHorizontalScroll: (dateTime) {
            //   // If the dates year, month, of week of month has changed do another get request
            //   if (getWeekOfMonth(currentTime.value) !=
            //           getWeekOfMonth(dateTime) ||
            //       currentTime.value.month != dateTime.month ||
            //       currentTime.value.year != dateTime.year) {
            //     onRefresh();
            //   }
            //   currentTime.value = dateTime;
            // },
          ),
        ),
      ),
    );
  }
}
