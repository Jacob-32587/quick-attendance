import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';

/// Based on the width of the screen, shows a modal or popover
/// which contains a form to join a group
void showInviteUserPopup(BuildContext context) {
  final isDesktop = GetPlatform.isDesktop;
  if (isDesktop) {
    // Show modal for desktop
    showDialog(
      context: context,
      builder: (context) {
        return _InviteUserModal();
      },
    );
  } else {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _InviteUserPopover();
      },
    );
  }
}

class _InviteUserModal extends StatelessWidget {
  late final GroupController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Invite User"),
      content: SizedBox(
        width: min(MediaQuery.of(context).size.width * 0.9, 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.group.value?.name.value != null)
              Text(
                "You are inviting to: '${controller.group.value!.name.value}'",
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).hintColor,
                ),
              ),
            const SizedBox(height: 16),
            _InviteUserForm(),
          ],
        ),
      ),
    );
  }
}

class _InviteUserPopover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Invite User",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _InviteUserForm(),
        ],
      ),
    );
  }
}

class _InviteUserForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InviteUserFormState();
}

class _InviteUserFormState extends State<_InviteUserForm> {
  final GroupController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  late final ProfileController profileController = Get.find();
  final RxBool inviteAsManager = false.obs;

  final RxnString _usernameError = RxnString();
  final RxBool inviteSent = false.obs;
  final RxBool disableInvite = false.obs;
  final RxBool isSendingInvite = false.obs;

  Future<void> onSubmit() async {
    if (disableInvite.value || !_formKey.currentState!.validate()) {
      return;
    }
    isSendingInvite.value = true;
    _usernameError.value = null;
    ApiResponse<Null>? response = await _controller.inviteUserToGroup(
      _usernameController.text,
      inviteAsManager.value,
    );
    isSendingInvite.value = false;
    if (response == null) {
      _usernameError.value = "Failed to send invite (group ID not set).";
      return;
    }
    if (response.statusCode == HttpStatusCode.notFound) {
      _usernameError.value = "This user does not exist";
    } else if (response.statusCode == HttpStatusCode.forbidden) {
      _usernameError.value = "Only the owner can invite users";
      disableInvite.value = true;
    } else if (response.statusCode == HttpStatusCode.conflict) {
      _usernameError.value = "This user is already invited";
    } else if (response.statusCode != HttpStatusCode.ok) {
      _usernameError.value = "The server failed to invite the user";
    }
    // Temporarily show the successfully invited message
    inviteSent.value = true;
    await Future.delayed(Duration(seconds: 3));
    inviteSent.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                errorText: _usernameError.value,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a username";
                }
                return null;
              },
            ),
          ),
          Obx(
            () => AnimatedOpacity(
              opacity: inviteSent.value ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Invite sent",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Invite as Manager",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Managers can take attendance and view members' unique IDs",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              value: inviteAsManager.value,
              onChanged: (value) {
                inviteAsManager.value = value ?? false;
              },
            ),
          ),
          SizedBox(height: 64),
          Row(
            children: [
              ElevatedButton(onPressed: () => Get.back(), child: Text("Close")),
              Spacer(),
              Obx(
                () => PrimaryButton(
                  text: "Invite",
                  onPressed: onSubmit,
                  isLoading: isSendingInvite.value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
