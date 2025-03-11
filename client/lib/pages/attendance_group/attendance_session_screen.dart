import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:quick_attendance/pages/attendance_group/components/qr-code-view.dart';

class GroupAttendanceSessionScreen extends StatelessWidget {
  late final ProfileController profileController = Get.find();
  final Rxn<GroupModel> group;
  GroupAttendanceSessionScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body: Obx(() {
        String? activeAccountId = profileController.user.value.userId;
        if (activeAccountId == null) {
          // User is not logged in
          return Center(
            child: Column(
              children: [
                Text(
                  "You must be logged in to use this feature.",
                  style: TextStyle(fontSize: 18),
                ),
                PrimaryButton(
                  onPressed: () => Get.toNamed("/login"),
                  text: "Login",
                ),
              ],
            ),
          );
        } else {
          // User is logged in
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("SCAN ME", style: TextStyle(fontSize: 36)),
                QrCodeView(code: activeAccountId),
              ],
            ),
          );
        }
      }),
    );
  }
}
