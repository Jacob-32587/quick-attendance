import 'package:flutter/material.dart';

/// Provides the generic parameters for all list widgets.
/// Created to unify the skeleton list and list widget for displaying groups
class GenericListWidget extends StatelessWidget {
  final bool isListView;
  final int itemCount;
  final Widget Function(BuildContext, int, bool isListView) buildListItem;

  const GenericListWidget({
    super.key,
    required this.isListView,
    required this.itemCount,
    required this.buildListItem,
  });

  @override
  Widget build(BuildContext context) {
    return isListView
        ? ListView.builder(
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) => buildListItem(context, index, true),
        )
        : GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) => buildListItem(context, index, false),
        );
  }
}
