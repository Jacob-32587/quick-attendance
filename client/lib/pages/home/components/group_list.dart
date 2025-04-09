import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/generic_list_widget.dart';
import 'package:quick_attendance/models/group_model.dart';

class GroupList extends StatelessWidget {
  final List<GroupModel>? groups;
  final bool isListView;
  final RxInt _shownGroups = RxInt(6);
  final RxString _searchTerm = RxString("");

  RxList<GroupModel> get filteredGroups {
    return RxList<GroupModel>.from(
      (groups ?? const [])
          .where(
            (group) => (group.name.value ?? "").toLowerCase().contains(
              _searchTerm.value.toLowerCase(),
            ),
          )
          .take(_shownGroups.value),
    );
  }

  GroupList({super.key, required this.groups, required this.isListView});

  int get groupCount => filteredGroups.length;
  int get groupsRemaining => (groups?.length ?? 0) - _shownGroups.value;
  bool get areGroupsHidden => groupsRemaining > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => GenericListWidget(
            isListView: isListView,
            itemCount: groupCount,
            buildListItem: (context, idx, isListView) {
              return _GroupCard(
                group: filteredGroups[idx],
                isListView: isListView,
              );
            },
          ),
        ),
        Obx(() {
          if (areGroupsHidden) {
            return TextButton(
              onPressed: () {
                _shownGroups.value *= 2;
              },
              child: Text(
                "Show More",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        }),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final bool isListView;
  final GroupModel group;
  const _GroupCard({required this.group, required this.isListView});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(group.name.value ?? ""),
        subtitle: Text(group.description.value ?? ""),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const Icon(Icons.arrow_forward_ios, size: 16)],
        ),
        onTap: () => Get.toNamed("/group/${group.groupId}"),
      ),
    );
  }
}
