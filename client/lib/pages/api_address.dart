import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/components/primary_button.dart';

class ApiAddress extends StatelessWidget {
  late final QuickAttendanceApi _api = Get.find();
  final TextEditingController _inputController = TextEditingController();

  ApiAddress({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.toNamed("/login"),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Text("Current: ${_api.domainAndPort.value}")),
              TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  labelText: "New Domain",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: "Save",
                onPressed: () {
                  _api.domainAndPort.value = "${_inputController.text}:8080";
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
