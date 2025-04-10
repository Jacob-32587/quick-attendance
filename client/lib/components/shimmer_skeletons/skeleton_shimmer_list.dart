import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/generic_list_widget.dart';
import 'package:shimmer/shimmer.dart';

/// A simple element that either displays an loading skeleton animation
/// for a list or the provided child widget based on the isLoading parameter.
class SkeletonShimmerList extends StatelessWidget {
  final RxBool isLoading;

  /// The widget to render when not in loading state.
  late final Widget _widget;
  final int itemCount;
  final bool isListView;
  final double? skeletonWidth;
  final double? skeletonHeight;
  SkeletonShimmerList({
    super.key,
    required this.isLoading,
    Widget? widget,
    this.isListView = true,
    this.itemCount = 8,
    this.skeletonWidth,
    this.skeletonHeight,
  }) {
    _widget = widget ?? const SizedBox.shrink();
  }
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BinaryChoice(
        choice: isLoading.value,
        widget1: GenericListWidget(
          isListView: isListView,
          itemCount: itemCount,
          buildListItem: (context, index, isListView) {
            return Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.onSurface.withAlpha(50),
              highlightColor: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha(100),
              period: Duration(seconds: 1),
              child: Container(
                width: skeletonWidth,
                height: skeletonHeight,
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(vertical: 4),
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
            );
          },
        ),
        widget2: _widget,
      ),
    );
  }
}
