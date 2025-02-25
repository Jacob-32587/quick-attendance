import 'package:flutter/material.dart';

class GroupHeader extends StatelessWidget {
  final List<Widget> children;
  final String title;

  const GroupHeader({super.key, required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        ...children,
      ],
    );
  }
}
