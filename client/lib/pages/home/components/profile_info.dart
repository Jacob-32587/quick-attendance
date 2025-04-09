import 'package:flutter/material.dart';
import 'package:quick_attendance/models/group_model.dart';

class ProfileInfo extends StatelessWidget {
  final String user;
  final String email;
  final String firstName;
  final String lastName;
  final List<GroupModel>? groups;

  const ProfileInfo({required this.firstName, required this.lastName, required this.user, required this.email, required this.groups});

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
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Divider(
              color: Colors.grey, // Line color
              thickness: 1,       // Line thickness
              indent: 5,         // Start padding
              endIndent: 5,      // End padding
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'First Name:  ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      TextSpan(
                        text: '$firstName',
                        style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                      )
                    ]
                  )
                 ),
                SizedBox(height: 25),
                RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Last Name:  ',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    TextSpan(
                      text: '$lastName',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                    )
                  ]
                )
                ),
                SizedBox(height: 25),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Username:  ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      TextSpan(
                        text: '$user',
                        style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                      )
                    ]
                  )
                ),
                SizedBox(height: 25),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Email:  ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      TextSpan(
                        text: '$email',
                        style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                      )
                    ]
                  )
                ),
                SizedBox(height: 25),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Member of:  ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      TextSpan(
                        text: '${groups?.length ?? 0} groups',
                        style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                      )
                    ]
                  )
                ),
                SizedBox(height: 10)
              ]
            )
          ]
        ),
    );
  }
}