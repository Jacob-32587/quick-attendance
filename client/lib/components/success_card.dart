import 'package:flutter/material.dart';

class SuccessCard extends StatelessWidget {
  final Widget child;
  SuccessCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade200),
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
