import 'package:flutter/material.dart';

// Use this file as a template for how to structure Flutter components
// Lets always put the State widget at the top of the page if the widget requires state.

// If you're curious about what a StatefulWidget is, it makes the class immutable. In your stateful widget, define your data variables.
// The immutability allows for module replacement to work smoothly.
// Every time Flutter's state changes, build() functions will be called, but
// createState() functions will not be re-called. Thus allowing data to persist.

// The super.key simply passes the key parameter to the StatelessWidget parent.
// In Flutter, keys are used as an optimization technique to identify widgets uniquely.
// Flutter will always try to reuse widgets, and update only the ones that need updated based on their keys.

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key, required this.title});

  // title goes here instead of the state because it is not meant to be changed!
  final String title;

  @override
  State<ExampleWidget> createState() => _ExampleState();
}

// Prefixing with underscore (_) makes the class private to the file.
class _ExampleState extends State<ExampleWidget> {
  // This is the state of the widget, and is meant to change.
  // All data that is meant to be changed over time should
  // be put in this class.
  int _count = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _count without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The build function determines how this widget renders on screen!
    throw UnimplementedError();
  }
}
