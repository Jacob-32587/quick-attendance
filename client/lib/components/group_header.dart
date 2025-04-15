import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';

class ListHeader extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final RxBool? isLoading;

  const ListHeader({
    super.key,
    required this.title,
    required this.children,
    this.isLoading,
  });
  @override
  Widget build(BuildContext context) {
    if (title.isEmpty && children.isEmpty) {
      return SizedBox.shrink();
    }
    return Row(
      children: [
        if (isLoading == null)
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        else
          SkeletonShimmer(
            isLoading: isLoading!,
            skeletonWidth: 300,
            skeletonHeight: 60,
            widget: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        Spacer(),
        ...children,
      ],
    );
  }
}
