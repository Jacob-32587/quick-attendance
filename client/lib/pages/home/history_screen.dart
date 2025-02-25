import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Attendance History",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            EasyDateTimeLinePicker(
              focusedDate: _selectedDate,
              firstDate: DateTime.now().subtract(Duration(days: 7)),
              lastDate: DateTime.now().add(Duration(days: 7)),
              selectionMode: SelectionMode.autoCenter(),
              onDateChange: (date) {
                print("Seleted $date");
                _selectedDate = date;
              },
            ),
          ],
        ),
      ),
    );
  }
}
