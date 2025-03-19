import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';

/// Based on the width of the screen, shows a modal or popover
/// which contains a form to join a group
void showJoinGroupPopup(BuildContext context) {
  final isDesktop = GetPlatform.isDesktop;
  if (isDesktop) {
    // Show modal for desktop
    showDialog(
      context: context,
      builder: (context) {
        return _JoinGroupModal();
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
        return _JoinGroupPopover();
      },
    );
  }
}

class _JoinGroupModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: Text("Enter Group Code"),
      content: _JoinGroupForm(),
    );
  }
}

class _JoinGroupPopover extends StatelessWidget {
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
      child: _JoinGroupForm(),
    );
  }
}

class _JoinGroupForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _JoinGroupFormState();
}

class _JoinGroupFormState extends State<_JoinGroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  late final ProfileController profileController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(labelText: "Code"),
            textCapitalization: TextCapitalization.characters, // Auto uppercase
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !RegExp(r'^[A-Za-z0-9]{8}$').hasMatch(value)) {
                return "Please enter a valid code";
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                profileController.joinGroup(_codeController.text.trim());
                Get.back();
              }
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
