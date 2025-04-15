import 'package:flutter/material.dart';

class DangerButton extends StatelessWidget {
  /* Specify the widget to render in the primary button. */
  final Widget? child;
  final VoidCallback? onPressed;
  /* Provide basic text to render in the primary button */
  final String? text;
  final double fontSize;
  final bool isLoading;

  const DangerButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.fontSize = 18,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        textStyle: TextStyle(fontSize: fontSize),
        foregroundColor: Colors.red.shade50,
        backgroundColor: Colors.red.shade800,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (child == null) ? Text(text ?? "Default") : child!,
          if (isLoading) ...[
            SizedBox(width: 10),
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: Colors.red.shade50,
                strokeWidth: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
