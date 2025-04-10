import 'package:flutter/material.dart';

class BinaryChoice extends StatelessWidget {
  /* The widget to display when choice is true */
  late final Widget _widget1;
  /* The widget to display when the choice is false */
  late final Widget _widget2;
  final bool choice;

  BinaryChoice({
    super.key,
    required this.choice,
    Widget? widget1,
    Widget? widget2,
  }) {
    _widget1 = widget1 ?? const SizedBox.shrink();
    _widget2 = widget2 ?? const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (choice) {
      return _widget1;
    } else {
      return _widget2;
    }
  }
}
