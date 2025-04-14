import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/binary_choice.dart';

class AsyncIconButton extends StatelessWidget {
  final RxBool isLoading = false.obs;
  final Future<void> Function() onPressed;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  AsyncIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  void callPressed() async {
    isLoading.value = true;
    try {
      await onPressed();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: callPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        fixedSize: Size(50, 50),
        alignment: Alignment.center,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Obx(
        () => BinaryChoice(
          choice: isLoading.value,
          widget1: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(color: iconColor),
          ),
          widget2: Icon(icon, color: iconColor, size: 30),
        ),
      ),
    );
  }
}
