import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  late final ProfileController _controller = Get.find();
  final String name;
  final String user;
  final String email;
  String getFirstLetter(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  ProfileHeader({required this.name, required this.user, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
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
                    color:
                        Theme.of(context).colorScheme.primary, // Outline color
                  ),
                ],
              ),
            ),
          ),
          SkeletonShimmer(
            skeletonWidth: 100,
            skeletonHeight: 30,
            isLoading: _controller.isFetchingProfile,
            widget: Text(
              name,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          SkeletonShimmer(
            skeletonWidth: 100,
            skeletonHeight: 30,
            isLoading: _controller.isFetchingProfile,
            widget: Text(
              "($user)",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 22, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
