import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/models/group_settings_model.dart';

/// Based on the width of the screen, shows a modal or popover
/// which contains a form to join a group
void showCreateGroupPopup(BuildContext context) {
  final isDesktop = GetPlatform.isDesktop;
  if (isDesktop) {
    // Show modal for desktop
    showDialog(
      context: context,
      builder: (context) {
        return _CreateGroupModal();
      },
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController, // connect scroll
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Create Group", style: TextStyle(fontSize: 20)),
                    SizedBox(height: 16),
                    _CreateGroupForm(), // your form here
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CreateGroupModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create Group"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: _CreateGroupForm(),
      ),
    );
  }
}

class _CreateGroupForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<_CreateGroupForm> {
  late final ProfileController profileController = Get.find();
  final TextEditingController promptController = TextEditingController();
  final TextEditingController minLengthController = TextEditingController(
    text: "1",
  );
  final TextEditingController maxLengthController = TextEditingController(
    text: "64",
  );
  final RxBool requiredForManagers = false.obs;

  /// Not part of the settings, but enables/disables adding unique_id_settings
  /// to the create group request
  final RxBool promptUsers = false.obs;
  final _formKey = GlobalKey<FormState>();
  final Rx<GroupSettingsModel> settings = Rx<GroupSettingsModel>(
    GroupSettingsModel(minLength: 1, maxLength: 64),
  );

  String? validatePrompt(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else if (value.length > 512) {
      return "Too long (${value.length}/512)";
    }
    return null;
  }

  String? validateMinLength(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a minimum length";
    }
    final number = int.tryParse(value);
    if (number == null) {
      return "Please enter a valid number";
    }
    if (number < 1 || number > 64) {
      return "Must be between 1 and 64";
    }
    final maxLength = int.tryParse(maxLengthController.text);
    if (maxLength != null && maxLength < number) {
      return "Must be less than the maximum length";
    }
  }

  String? validateMaxLength(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a maximum length";
    }
    final number = int.tryParse(value);
    if (number == null) {
      return "Please enter a valid number";
    }
    if (number < 1 || number > 64) {
      return "Must be between 1 and 64";
    }
    final minLength = int.tryParse(minLengthController.text);
    if (minLength != null && minLength > number) {
      return "Must be greater than minimum length";
    }
  }

  void submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Form was invalid
      return;
    }

    GroupSettingsModel? uniqueIdSettings = null;
    if (promptUsers.value) {
      uniqueIdSettings = settings.value;
      var maxLength = int.tryParse(maxLengthController.text);
      var minLength = int.tryParse(minLengthController.text);
      var promptMessage = promptController.text;
      if (maxLength == null || minLength == null || promptMessage == null) {
        Get.snackbar(
          "Error",
          "Failed to create group",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.deepOrange,
          colorText: Colors.white,
        );
        return;
      }
      uniqueIdSettings.maxLength.value = maxLength;
      uniqueIdSettings.minLength.value = minLength;
      uniqueIdSettings.promptMessage.value = promptMessage;
    }
    String? newGroupId = await profileController.createGroup(
      settings: uniqueIdSettings,
    );
    if (newGroupId == null) {
      return;
    }
    Get.back(); // close the popup
    Get.toNamed("/group/$newGroupId");
    Get.snackbar(
      "Success!",
      "You have created a group.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Configure the group settings here. You won't be able to change these after creating the group!",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => CheckboxListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Require ID Prompt",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Prompt users to enter a unique ID when they join the group",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              value: promptUsers.value,
              onChanged: (value) {
                promptUsers.value = value ?? false;
              },
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color:
                    promptUsers.value
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.onSurface.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              height: promptUsers.value ? null : 0,
              child:
                  promptUsers.value
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: promptController,
                            maxLength: 512,
                            minLines: 2,
                            maxLines: null, // expand vertically
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              labelText: "Prompt Message *",
                              border: OutlineInputBorder(),
                            ),
                            validator: validatePrompt,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: minLengthController,
                            decoration: const InputDecoration(
                              labelText: "Minimum Length *",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: validateMinLength,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: maxLengthController,
                            decoration: const InputDecoration(
                              labelText: "Maximum Length *",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: validateMaxLength,
                          ),
                          const SizedBox(height: 12),
                          Obx(
                            () => CheckboxListTile(
                              title: const Text(
                                "Require ID from Managers",
                                style: TextStyle(fontSize: 14),
                              ),
                              value:
                                  settings.value.requireManagerId.value ??
                                  false,
                              onChanged: (value) {
                                settings.value.requireManagerId.value =
                                    value ?? false;
                              },
                            ),
                          ),
                        ],
                      )
                      : SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [PrimaryButton(onPressed: submitForm, text: "Finish")],
          ),
        ],
      ),
    );
  }
}
