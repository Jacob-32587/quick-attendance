import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/primary_button.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<StatefulWidget> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final AuthController authController = Get.find();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  void signup() {
    if (_formKey.currentState!.validate()) {
      bool response = authController.signUp(
        _emailController.text.trim(),
        _usernameController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (response) {
        Get.snackbar("Awesome!", "You joined a new group!");
      }
    }
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
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: "Password *",
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your password";
              }
              if (value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: "Confirm Password *",
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
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
          SizedBox(height: 20),
          PrimaryButton(text: "Signup", onPressed: signup),
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

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
