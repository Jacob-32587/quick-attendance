import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/history_controller.dart';
import 'package:quick_attendance/util/time.dart';

class HistoryScreen extends StatelessWidget {
  late final HistoryController _historyController = Get.find();

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DayView(
      controller: _historyController.calendarEventController,
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
      maxDay: DateTime.now(),
      scrollPhysics: BouncingScrollPhysics(),
      onPageChange: (DateTime? time, int? i) {
        if (time != null) {
          if (getWeekOfMonth(time) !=
              getWeekOfMonth(_historyController.currentDate.value)) {
            _historyController.currentDate.value = time;
            _historyController.onRefresh();
          } else {
            _historyController.currentDate.value = time;
          }
        }
      },
    );
  }
}
