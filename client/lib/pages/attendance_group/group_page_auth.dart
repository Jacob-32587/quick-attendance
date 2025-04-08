import 'package:flutter/material.dart';
import 'package:quick_attendance/pages/attendance_group/components/group_page.dart';
import 'package:quick_attendance/pages/auth/auth_gate.dart';

class GroupPageAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGate(page: GroupPage());
  }
}
