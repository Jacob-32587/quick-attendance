import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/controllers/history_controller.dart';
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
}

class HistoryScreen extends StatelessWidget {
  late final HistoryController _historyController = Get.find();
  final _calendarEventController = EventController<_AttendanceEventData?>();
  final clearedData = RxBool(false);
  final currentDate = Rx<DateTime>(DateTime.now());

  late final QuickAttendanceApi _api = Get.find();
  final attendanceHistory = Rxn<AttendanceHistoryModel>();

  HistoryScreen({super.key}) {
    _calendarEventController.removeWhere((x) => true);
    onRefresh();
  }

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
    await _historyController.getAttendanceHistoryForWeek(currentDate.value);
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

    var storedEventsIds =
        _calendarEventController.allEvents
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
    _calendarEventController.addAll(newEvents);
  }

  CalendarEventData<_AttendanceEventData>? _getCalendarEventData(
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
      return CalendarEventData<_AttendanceEventData>(
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
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scaffold(
        body: SafeArea(
          child: DayView(
            controller: _calendarEventController,
            backgroundColor: Theme.of(context).colorScheme.surface,
            heightPerMinute: 2,
            headerStyle: HeaderStyle(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              leftIconConfig: IconDataConfig(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              rightIconConfig: IconDataConfig(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            scrollPhysics: BouncingScrollPhysics(),
            onPageChange: (DateTime? time, int? i) {
              if (time != null) {
                if (getWeekOfMonth(time) != getWeekOfMonth(currentDate.value)) {
                  currentDate.value = time;
                  onRefresh();
                } else {
                  currentDate.value = time;
                }
              }
            },
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
