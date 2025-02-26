import 'package:flutter/material.dart';
import 'package:quick_attendance/pages/auth/login.dart';

class LoggedOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Use or make an account to continue",
                style: TextStyle(fontSize: 21),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text("Login"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Go to sign-up page
                },
                child: Text("Sign-up (WIP)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
