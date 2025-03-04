import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  /* Specify the widget to render in the primary button. */
  final Widget? child;
  final VoidCallback? onPressed;
  /* Provide basic text to render in the primary button */
  final String? text;
  final double fontSize;

  const PrimaryButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        textStyle: TextStyle(fontSize: fontSize),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: (child == null) ? Text(text ?? "Default") : child,
    );
  }
}
