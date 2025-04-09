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

  ProfileInfo({required this.firstName, required this.lastName, required this.user, required this.email, required this.groups});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    final TextEditingController _emailController = TextEditingController(text: '$email');
    final TextEditingController _usernameController = TextEditingController(text: '$user');
    final TextEditingController _firstNameController = TextEditingController(text: '$firstName');
    final TextEditingController _lastNameController = TextEditingController(text: '$lastName');

    void updateInfo() async {
      if (_formKey.currentState!.validate() == false) {
        return;
      }
      await profileController.updateUserAccount(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim()
      );
      
      Get.snackbar("Success", "Profile updated successfully", snackPosition: SnackPosition.BOTTOM);
      // TODO: variable to trigger restart
    }

    return Container( 
      width: 500,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
      border: Border.all(
        color: Colors.white, // Border color
        width: 1, // Border width
      ),
      borderRadius: BorderRadius.circular(8),
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),
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