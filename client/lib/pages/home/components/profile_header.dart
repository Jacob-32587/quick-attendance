import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String user;
  final String email;
  String getFirstLetter(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  const ProfileHeader({required this.name, required this.user, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container( 
      decoration: BoxDecoration(
      border: Border.all(
        color: Colors.white, // Border color
        width: 1, // Border width
      ),
      borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              getFirstLetter(name),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 40,
                shadows: [
                  Shadow(
                    offset: Offset(1.5, 1.5), // Position of the shadow
                    blurRadius: 2.0, // How much the shadow spreads
                    color: Theme.of(context).colorScheme.primary, // Outline color
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height:10),
          Text(
            name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            "Username: $user",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 5),
          Text(
            "Email: $email",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      )
    );
  }
}