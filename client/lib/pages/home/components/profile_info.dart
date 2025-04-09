import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String name;
  final String user;
  final String email;
  
  const ProfileInfo({required this.name, required this.user, required this.email});

  @override
  Widget build(BuildContext context) {
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
      child: 
        Column(
          children: [
            Text(
              "Account Information",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(
              color: Colors.grey, // Line color
              thickness: 1,       // Line thickness
              indent: 5,         // Start padding
              endIndent: 5,      // End padding
            )
          ]
        ),
    );
  }
}