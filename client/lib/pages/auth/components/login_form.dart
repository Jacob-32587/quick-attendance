import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/_api_client.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/models/responses/login_response.dart';

class LoginForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final QuickAttendanceApi _api = Get.find();
  final AuthController authController = Get.find();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _isPasswordVisible = false.obs; // toggle password visibility
  // Displays an error message underneath the email input
  final RxnString _emailError = RxnString();
  // Displays an error message underneath the password input
  final RxnString _passwordError = RxnString();
  final RxBool _isLoading = false.obs;

  void _login() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    _isLoading.value = true;
    // Perform login action
    ApiResponse<LoginResponse> response = await _api.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    _isLoading.value = false;

    _emailError.value = null;
    _passwordError.value = null;
    if (response.statusCode == HttpStatusCode.ok) {
      await authController.saveJwt(response.body?.jwt);
      Get.toNamed("/");
    } else if (response.statusCode == HttpStatusCode.notFound) {
      // The email was not found
      _emailError.value = "Email not found";
    } else if (response.statusCode == HttpStatusCode.badRequest ||
        response.statusCode == HttpStatusCode.unauthorized) {
      // The password entered was not correct
      _passwordError.value = "Password is incorrect";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: Text(
                "Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              onLongPress: () => Get.toNamed("/manual-address"),
            ),
            SizedBox(height: 20),
            Obx(
              () => TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                  errorText: _emailError.value,
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
            ),
            SizedBox(height: 15),
            Obx(
              () => TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  errorText: _passwordError.value,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
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
            SizedBox(height: 20),
            Obx(
              () => PrimaryButton(
                text: "Login",
                onPressed: _login,
                isLoading: _isLoading.value,
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.offNamed("/signup");
              },
              child: Text("Don't have an account?"),
            ),
          ],
        ),
      ),
    );
  }
}
