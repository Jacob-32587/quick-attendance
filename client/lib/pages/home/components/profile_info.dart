import 'package:flutter/material.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/models/group_model.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/components/primary_button.dart';

class ProfileInfo extends StatelessWidget {
  final String user;
  final String email;
  final String firstName;
  final String lastName;
  final List<GroupModel>? groups;
  final _formKey = GlobalKey<FormState>();
  final RxBool _isSavingProfile = false.obs;
  final RxnString _responseError = RxnString();

  late final ProfileController profileController = Get.find();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  ProfileInfo({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.user,
    required this.email,
    required this.groups,
  }) {
    _emailController = TextEditingController(text: email);
    _usernameController = TextEditingController(text: user);
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
  }

  void updateInfo() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    _isSavingProfile.value = true;
    _responseError.value = null;
    final response = await profileController.updateUserAccount(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    if (response.statusCode == HttpStatusCode.conflict) {
      _responseError.value = "Username or email already taken";
    } else {
      await profileController.fetchProfileData();
    }
    _isSavingProfile.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Edit Account Information",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              spacing: 24,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a valid username";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    ).hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                Obx(
                  () => BinaryChoice(
                    choice: _responseError.value != null,
                    widget1: Column(
                      children: [
                        Text(
                          _responseError.value ?? "",
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () => PrimaryButton(
                    text: "Save",
                    onPressed: updateInfo,
                    isLoading: _isSavingProfile.value,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
