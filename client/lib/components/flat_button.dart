import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FlatButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: padding,
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.surface,
          foregroundColor:
              foregroundColor ?? Theme.of(context).colorScheme.primary,
        ),
        child: child,
      ),
    );
  }
}
