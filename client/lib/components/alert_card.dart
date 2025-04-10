import 'package:flutter/material.dart';

/// Display a red-colored card with a leading warning icon and customizable content.
class AlertCard extends StatelessWidget {
  /// The content of the alert message. Usually just text.
  final Widget child;
  final double? width;
  final double? height;

  AlertCard({required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade100),
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
