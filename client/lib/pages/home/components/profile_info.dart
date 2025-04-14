import 'package:flutter/material.dart';
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

  final ProfileController profileController = Get.find();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  ProfileInfo({required this.firstName, required this.lastName, required this.user, required this.email, required this.groups}) {
    _emailController = TextEditingController(text: '$email');
    _usernameController = TextEditingController(text: '$user');
    _firstNameController = TextEditingController(text: '$firstName');
    _lastNameController = TextEditingController(text: '$lastName');
  }

  void updateInfo() async {
      if (_formKey.currentState!.validate() == false) {
        return;
      }
      profileController.updateUserAccount(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim()
      );

      // Now update the observable user in the controller
      final updatedUser = profileController.user.value!;
      updatedUser.username.value = _usernameController.text.trim();
      updatedUser.email.value = _emailController.text.trim();
      updatedUser.firstName.value = _firstNameController.text.trim();
      updatedUser.lastName.value = _lastNameController.text.trim();

      // Trigger UI update
      profileController.user.refresh();
      
      Get.snackbar("Success!", "Profile updated successfully.", snackPosition: SnackPosition.BOTTOM);
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
          Divider(
            color: Colors.grey, // Line color
            thickness: 1,       // Line thickness
            indent: 5,         // Start padding
            endIndent: 5,      // End padding
          ),
          Form(
            key: _formKey,
            child: Column(
     
              children: [
                SizedBox(height: 10),
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
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                SizedBox(height: 25),
                PrimaryButton(text: "Save", onPressed: updateInfo),
                SizedBox(height: 10)
              ]
            )
          )
        ]
      ),
    );
  }
}