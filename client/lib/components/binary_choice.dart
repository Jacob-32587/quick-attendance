import 'package:flutter/material.dart';

class BinaryChoice extends StatelessWidget {
  /* The widget to display when choice is true */
  final Widget widget1;
  /* The widget to display when the choice is false */
  final Widget widget2;
  final bool choice;

  const BinaryChoice({
    super.key,
    required this.choice,
    this.widget1 = const SizedBox.shrink(),
    this.widget2 = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    if (choice) {
      return widget1;
    } else {
      return widget2;
    }
  }
}
