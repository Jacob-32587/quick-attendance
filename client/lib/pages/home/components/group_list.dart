import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/models/group_model.dart';

class GroupList extends StatelessWidget {
  final List<GroupModel> groups;
  final bool isListView;
  const GroupList({super.key, required this.groups, required this.isListView});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isListView
            ? Obx(
              () => ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder:
                    (context, index) => _GroupCard(
                      group: groups[index],
                      isListView: isListView,
                    ),
              ),
            )
            : Obx(
              () => GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3,
                ),
                itemCount: groups.length,
                itemBuilder:
                    (context, index) => _GroupCard(
                      group: groups[index],
                      isListView: isListView,
                    ),
              ),
            ),
        if (groups.length >= 4)
          TextButton(
            onPressed: () => {},
            child: Text("Show More", style: TextStyle(color: Colors.lightBlue)),
          ),
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
        title: Text(group.name.value),
        subtitle: Text(group.description.value),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const Icon(Icons.arrow_forward_ios, size: 16)],
        ),
        onTap: () => Get.toNamed("/group/${group.groupId}"),
      ),
    );
  }
}
