import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final Widget child;
  InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue[200]),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 25,
            color: Colors.grey.shade300.withAlpha(100),
          ), // vertical bar
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
