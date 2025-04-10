import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/generic_list_widget.dart';
import 'package:quick_attendance/models/public_user_model.dart';
import 'package:quick_attendance/pages/attendance_group/components/user_card.dart';

class UserList extends StatelessWidget {
  final List<PublicUserModel>? users;
  final bool isListView;
  final RxInt _shownUsers = RxInt(6);
  final RxString _searchTerm = RxString("");
  final bool displayAttended;

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

  UserList({
    super.key,
    required this.users,
    required this.isListView,
    this.displayAttended = false,
  });

  int get userCount => filteredUsers.length;
  int get usersRemaining => (users?.length ?? 0) - _shownUsers.value;
  bool get areUsersHidden => usersRemaining > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => GenericListWidget(
            isListView: isListView,
            itemCount: userCount,
            buildListItem: (context, idx, isListView) {
              return UserCard(
                user: filteredUsers[idx],
                isListView: isListView,
                displayAttended: displayAttended,
              );
            },
          ),
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
