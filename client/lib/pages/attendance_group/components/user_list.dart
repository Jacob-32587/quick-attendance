import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/generic_list_widget.dart';
import 'package:quick_attendance/models/public_user_model.dart';

class UserList extends StatelessWidget {
  final List<PublicUserModel>? users;
  final bool isListView;
  final RxInt _shownUsers = RxInt(6);
  final RxString _searchTerm = RxString("");

  RxList<PublicUserModel> get filteredUsers {
    return RxList<PublicUserModel>.from(
      (users ?? const [])
          .where(
            (user) =>
                (user.username.value).toLowerCase().contains(
                  _searchTerm.value.toLowerCase(),
                ) ||
                (user.firstName.value).toLowerCase().contains(
                  _searchTerm.value.toLowerCase(),
                ) ||
                (user.lastName.value ?? "").toLowerCase().contains(
                  _searchTerm.value.toLowerCase(),
                ),
          )
          .take(_shownUsers.value),
    );
  }

  UserList({super.key, required this.users, required this.isListView});

  int get userCount => filteredUsers.length;
  int get usersRemaining => (users?.length ?? 0) - _shownUsers.value;
  bool get areUsersHidden => usersRemaining > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenericListWidget(
          isListView: isListView,
          itemCount: userCount,
          buildListItem: (context, idx, isListView) {
            return _UserCard(user: filteredUsers[idx], isListView: isListView);
          },
        ),
        Obx(() {
          if (areUsersHidden) {
            return TextButton(
              onPressed: () {
                _shownUsers.value *= 2;
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

class _UserCard extends StatelessWidget {
  final bool isListView;
  final PublicUserModel user;
  const _UserCard({required this.user, required this.isListView});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // I don't think this needs to be reactive because users
            // don't change their name dynamically.
            Text(
              "${user.firstName.value} ${user.lastName.value ?? ""}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              user.username.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600]!.withAlpha(200),
              ),
            ),
          ],
        ),
        leading:
            isListView
                ? CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )
                : null,
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child:
              user.uniqueId.value != null
                  ? Text(
                    "ID: ${user.uniqueId.value}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  )
                  : null,
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: []),
      ),
    );
  }
}
