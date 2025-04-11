import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:quick_attendance/controllers/history_controller.dart';
import 'package:intl/intl.dart';
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
  final HistoryController _historyController = Get.find();
  final EventsController _calendarEventController = Get.find();
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
                  y.attendanceTime.value,
                  y.attendanceId.value,
                  y.present.value,
                ),
              ),
            )
            .expand((e) => e)
            .nonNulls
            .toList() ??
        [];

    _calendarEventController.updateCalendarData((z) {
      var storedEventsIds = z.dayEvents.values
          .expand((e) => e)
          .map((x) => _AttendanceEventData.castObj(x.data)?.getEventId());

      var newEvents =
          events
              .where(
                (x) =>
                    !storedEventsIds.contains(
                      _AttendanceEventData.castObj(x.data)?.getEventId(),
                    ),
              )
              .toList();

      if (newEvents.isEmpty) {
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
    bool? present,
  ) {
    if (groupName != null &&
        attendanceTime != null &&
        groupId != null &&
        attendanceId != null &&
        present != null) {
      return Event(
        title: groupName,
        startTime: attendanceTime.toLocal(),
        endTime: attendanceTime.add(const Duration(minutes: 60)).toLocal(),
        color: present ? Colors.blue : Colors.red,
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
    _calendarEventController.updateCalendarData((x) {
      x.clearAll();
      onRefresh();
    });
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scaffold(
        appBar: AppBar(title: Text("Attendance Calendar")),
        body: SafeArea(
          child: EventsPlanner(
            controller: _calendarEventController,
            heightPerMinute: 0.9,
            daysShowed: 3,
            onAutomaticAdjustHorizontalScroll: (dateTime) {
              // If the dates year, month, of week of month has changed do another get request
              if (getWeekOfMonth(currentTime.value) !=
                      getWeekOfMonth(dateTime) ||
                  currentTime.value.month != dateTime.month ||
                  currentTime.value.year != dateTime.year) {
                onRefresh();
              }
              currentTime.value = dateTime;
            },
            fullDayParam: FullDayParam(fullDayEventsBarVisibility: false),
            daysHeaderParam: DaysHeaderParam(
              dayHeaderBuilder: (day, isToday) {
                return DefaultDayHeader(
                  dayText: DateFormat("E d").format(day).toString(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
