import 'package:flutter/material.dart';
import 'package:quick_attendance/models/public_user_model.dart';
import 'package:quick_attendance/models/user_type.dart';

class UserCard extends StatelessWidget {
  final bool isListView;
  final bool displayAttended;
  final PublicUserModel user;
  const UserCard({
    super.key,
    required this.user,
    required this.isListView,
    required this.displayAttended,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // I don't think this needs to be reactive because users
                // don't change their name dynamically.
                Text(
                  "${user.firstName.value} ${user.lastName.value ?? ""}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                if (displayAttended)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        size: 16 * 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (displayAttended) const SizedBox(width: 10),
                if (user.userType.value == UserType.owner ||
                    user.userType.value == UserType.manager)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          user.userType.value == UserType.owner
                              ? Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withAlpha(200)
                              : Theme.of(
                                context,
                              ).colorScheme.secondaryContainer.withAlpha(200),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.userType.value!.value,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              "${user.username.value} ${user.uniqueId.value != null ? "(${user.uniqueId.value ?? ""})" : ""}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600]!.withAlpha(200),
              ),
            ),
          ],
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Icon(
            Icons.person,
            size: 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: []),
      ),
    );
  }
}
