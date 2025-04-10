import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer_list.dart';
import 'package:quick_attendance/controllers/history_controller.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryController _historyController = Get.find();
  final EventController _calendarEventController = Get.find();

  HistoryScreen({super.key});

  Future<void> onRefresh() async {
    _historyController.attendanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance Calendar")),
      body: SafeArea(
        child: WeekView(
          backgroundColor: Theme.of(context).colorScheme.surface,
          headerStyle: HeaderStyle(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          scrollPhysics: BouncingScrollPhysics(),
          controller: _calendarEventController,
          // showLiveTimeLineInAllDays:
          //     true, // To display live time line in all pages in week view.
          // // width: fl, // width of week view.
          // minDay: DateTime(1990),
          maxDay: DateTime.now(),
          // initialDay: DateTime(2021),
          heightPerMinute: 1, // height occupied by 1 minute time span.
          // eventArranger:
          //     SideEventArranger(), // To define how simultaneous events will be arranged.
          // onEventTap: (events, date) => print(events),
          // onEventDoubleTap: (events, date) => print(events),
          // onDateLongPress: (date) => print(date),
          // startDay: WeekDays.sunday, // To change the first day of the week.
          // startHour: 5, // To set the first hour displayed (ex: 05:00)
          // endHour: 20, // To set the end hour displayed
          showVerticalLines: false, // Show the vertical line between days.
          weekPageHeaderBuilder: WeekHeader.hidden, // To hide week header
          showWeekDayAtBottom: false,
          fullDayHeaderTitle: 'All day',
          // fullDayHeaderTitle: 'All day', // To set full day events header title
          // fullDayHeaderTextConfig: FullDayHeaderTextConfig(
          //   textAlign: TextAlign.center,
          //   textOverflow: TextOverflow.ellipsis,
          //   maxLines: 2,
          // ), // To set full day events header text config
          // keepScrollOffset:
          //     true, // To maintain scroll offset when the page changes
        ),
      ),
    );
  }
}
