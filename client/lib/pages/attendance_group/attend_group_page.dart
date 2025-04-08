import 'package:flutter/material.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';
import 'package:quick_attendance/pages/auth/auth_gate.dart';

class AttendGroupAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGate(page: AttendGroupPage());
  }
}

class AttendGroupPage extends UrlGroupPage {
  @override
  Widget buildWithController(BuildContext context, GroupController controller) {
    return Scaffold();
  }
}
