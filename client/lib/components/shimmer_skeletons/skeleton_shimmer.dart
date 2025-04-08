import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:shimmer/shimmer.dart';

/// A simple element that either displays a loading skeleton animation or
/// the provided child widget based on the isLoading parameter.
class SkeletonShimmer extends StatelessWidget {
  final RxBool isLoading;

  /// The widget to render when not in loading state.
  final Widget widget;
  final double skeletonHeight;
  final double skeletonWidth;
  const SkeletonShimmer({
    super.key,
    required this.isLoading,
    required this.widget,
    this.skeletonHeight = 100,
    this.skeletonWidth = double.infinity,
  });
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BinaryChoice(
        choice: isLoading.value,
        widget1: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.onSurface.withAlpha(50),
          highlightColor: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha(100),
          period: Duration(seconds: 1),
          child: Container(
            padding: EdgeInsets.all(16.0),
            height: skeletonHeight,
            width: skeletonWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        widget2: widget,
      ),
    );
  }
}
