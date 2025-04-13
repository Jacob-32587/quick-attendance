import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;

  const FlatButton({
    super.key,
    required this.onPressed,
    this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.foregroundColor,
    this.backgroundColor,
    this.isLoading = false,
    this.text = "",
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
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
