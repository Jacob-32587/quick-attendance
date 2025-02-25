import 'package:flutter/material.dart';

// This is an example of a stateless widget.
// When your component does not need to change over time, a stateless widget
// is far more performant and less verbose than a stateful one!

// The super.key simply passes the key parameter to the StatelessWidget parent.
// In Flutter, keys are used as an optimization technique to identify widgets uniquely.
// Flutter will always try to reuse widgets, and update only the ones that need updated based on their keys.

class ExampleStatelessWidget extends StatelessWidget {
  final String title;

  const ExampleStatelessWidget({super.key, required this.title})

  @override
  Widget build(BuildContext context) {
    // The build function determines how this widget renders on screen!
    throw UnimplementedError();
  }
}
