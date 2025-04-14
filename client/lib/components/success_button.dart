import 'package:flutter/material.dart';

class SuccessButton extends StatelessWidget {
  /* Specify the widget to render in the primary button. */
  final Widget? child;
  final VoidCallback? onPressed;
  /* Provide basic text to render in the primary button */
  final String? text;
  final double fontSize;
  final bool isLoading;

  const SuccessButton({
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
        foregroundColor: Colors.green.shade900,
        backgroundColor: Colors.green.shade200,
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
                color: Colors.green.shade900,
                strokeWidth: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
