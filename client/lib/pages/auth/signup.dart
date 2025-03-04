import 'package:flutter/material.dart';
import 'package:quick_attendance/pages/auth/components/signup_form.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Center(child: SignupForm())],
          ),
        ),
      ),
    );
  }
}
