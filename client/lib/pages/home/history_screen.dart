import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:quick_attendance/controllers/history_controller.dart';

class _AttendanceEventData {
  late String attendanceId;
  late String groupId;
  _AttendanceEventData({
    required String attendanceId,
    required String groupId,
  }) {
    this.attendanceId;
    this.groupId;
  }
}

class HistoryScreen extends StatelessWidget {
  final HistoryController _historyController = Get.find();
  final EventsController _calendarEventController = Get.find();

  HistoryScreen({super.key});

  Future<void> onRefresh() async {
    await _historyController.getAttendanceHistoryForWeek();
    var events =
        _historyController.attendanceHistory.value?.attendance
            .map(
              (x) => x.attendanceRecords.map(
                (y) => _getCalendarEventData(
                  x.groupName.value,
                  x.groupId.value,
                  y.attendanceTime.value,
                  y.attendanceId.value,
                ),
              ),
            )
            .expand((e) => e)
            .nonNulls
            .toList() ??
        [];
    print(events);
    _calendarEventController.updateCalendarData((z) {
      var newEvents =
          z.dayEvents.values
              .expand((e) => e)
              .where(
                (x) =>
                    events.any(
                      (y) =>
                          (y.data as _AttendanceEventData).attendanceId !=
                          (x.data as _AttendanceEventData).attendanceId,
                    ) !=
                    true,
              )
              .toList();
      if (newEvents.length <= 0) {
        return;
      }
      return z.addEvents(newEvents);
    });
  }

  Event? _getCalendarEventData(
    String? groupName,
    String? groupId,
    DateTime? attendanceTime,
    String? attendanceId,
  ) {
    if (groupName != null &&
        attendanceTime != null &&
        groupId != null &&
        attendanceId != null) {
      return Event(
        title: groupName,
        startTime: attendanceTime.toLocal(),
        endTime: attendanceTime.add(const Duration(minutes: 60)).toLocal(),
        data: _AttendanceEventData(
          attendanceId: attendanceId,
          groupId: groupId,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    onRefresh();
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scaffold(
        appBar: AppBar(title: Text("Attendance Calendar")),
        body: SafeArea(
          child: EventsPlanner(
            controller: _calendarEventController,
            heightPerMinute: 0.9,
            daysShowed: 3,
          ),
        ),
      ),
    );
  }
}
