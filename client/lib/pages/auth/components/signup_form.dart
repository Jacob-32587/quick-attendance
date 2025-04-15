import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

class SignupForm extends StatelessWidget {
  final AuthController authController = Get.find();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isConfirmPasswordVisible = false.obs;
  final RxBool _isLoading = false.obs;
  final RxnString _responseError = RxnString();
  void signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _isLoading.value = true;
    _responseError.value = null;
    Response response = await authController.signUp(
      _emailController.text.trim(),
      _usernameController.text.trim(),
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _passwordController.text.trim(),
    );
    if (response.statusCode == 200) {
      Get.snackbar(
        "Awesome!",
        "You made an account! Now login to get access.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.green.shade50,
      );
      Get.toNamed("/login");
    } else if (response.statusCode == 409) {
      _responseError.value = response.body?["message"];
    }
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Sign Up",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email *",
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
            ),
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
          SizedBox(height: 15),
          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: "Username *",
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _firstNameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: "First Name *",
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your first name";
              }
              return null;
            },
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _lastNameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: "Last Name",
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              // Users don't need a last name
              return null;
            },
          ),
          SizedBox(height: 15),
          Obx(
            () => TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible.value,
              decoration: InputDecoration(
                labelText: "Password *",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Obx(
                    () => Icon(
                      _isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  onPressed: () {
                    _isPasswordVisible.value = !_isPasswordVisible.value;
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your password";
                }
                if (value.length < 8) {
                  return "Password must be at least 8 characters";
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 15),
          Obx(
            () => TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible.value,
              decoration: InputDecoration(
                labelText: "Confirm Password *",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Obx(
                    () => Icon(
                      _isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  onPressed: () {
                    _isConfirmPasswordVisible.value =
                        !_isConfirmPasswordVisible.value;
                  },
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text.trim()) {
                  return "Your passwords do not match";
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => BinaryChoice(
              choice: _responseError.value != null,
              widget1: Column(
                children: [
                  Text(
                    _responseError.value ?? "",
                    style: TextStyle(color: Colors.red.shade400, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Obx(
            () => PrimaryButton(
              text: "Signup",
              onPressed: signup,
              isLoading: _isLoading.value,
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Get.toNamed("/login");
            },
            child: Text("Already have an account?"),
          ),
        ],
      ),
    );
  }
}
