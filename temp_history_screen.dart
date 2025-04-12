import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalender/kalender.dart';
import 'package:quick_attendance/controllers/history_controller.dart';
import 'package:intl/intl.dart';
import 'package:quick_attendance/util/time.dart';

class AttendanceEventData {
  late String attendanceId;
  late String groupId;
  late String groupName;

  AttendanceEventData({
    required String attendanceId,
    required String groupId,
    required String groupName,
  }) {
    this.attendanceId = attendanceId;
    this.groupId = groupId;
    this.groupName = groupName;
  }

  String getEventId() {
    return attendanceId + groupId;
  }

  static AttendanceEventData? castObj(Object? obj) {
    if (obj == AttendanceEventData) {
      return obj as AttendanceEventData;
    }
    return null;
  }

  @override
  String toString() {
    return groupName;
  }
}

class HistoryScreen extends StatelessWidget {
  final HistoryController _historyController = Get.find();
  final DefaultEventsController<AttendanceEventData> _calendarEventController =
      Get.find();
  final CalendarController<AttendanceEventData> _calendarController =
      Get.find();
  final clearedData = RxBool(false);
  final currentTime = Rx<DateTime>(DateTime.now());

  HistoryScreen({super.key});

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

    var storedEventIds = _calendarEventController.dateMap.events.nonNulls.map(
      (x) => x.data?.getEventId(),
    );

    var newEvents =
        events
            .where((x) => !storedEventIds.contains(x.data?.getEventId()))
            .toList();

    if (newEvents.isEmpty) {
      return;
    }
    _calendarEventController.addEvents(newEvents);
  }

  CalendarEvent<AttendanceEventData>? _getCalendarEventData(
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
      return CalendarEvent<AttendanceEventData>(
        canModify: false,
        dateTimeRange: DateTimeRange(
          start: attendanceStartTime.toLocal(),
          end: attendanceEndTime.toLocal(),
        ),
        data: AttendanceEventData(
          attendanceId: attendanceId,
          groupId: groupId,
          groupName: groupName,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _calendarEventController.clearEvents();
    onRefresh();
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scaffold(
        appBar: AppBar(title: Text("Attendance Calendar")),
        body: SafeArea(
          child: CalendarView(
            eventsController: _calendarEventController,
            calendarController: _calendarController,
            viewConfiguration: MultiDayViewConfiguration.custom(
              numberOfDays: 3,
            ),
          ),
        ),
      ),
    );
  }
}
