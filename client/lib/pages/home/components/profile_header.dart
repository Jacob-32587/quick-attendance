import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  late final ProfileController _controller = Get.find();
  String getFirstLetter(String? name) {
    return name?.isNotEmpty == true ? name![0].toUpperCase() : '';
  }

  ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: EdgeInsets.all(16.0),
      child: Card(
        elevation: 7,
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.grey.shade400,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  "https://cdn.pixabay.com/photo/2022/09/15/06/14/pattern-7455773_1280.png",
                ),
                child: Obx(
                  () => Text(
                    getFirstLetter(_controller.firstName),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      shadows: [
                        Shadow(
                          offset: Offset(1.5, 1.5), // Position of the shadow
                          blurRadius: 2.0, // How much the shadow spreads
                          color: Colors.black54, // Outline color
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    SkeletonShimmer(
                      skeletonWidth: 120,
                      skeletonHeight: 30,
                      isLoading: _controller.isFetchingProfile,
                      widget: Obx(
                        () => Text(
                          "${_controller.firstName},",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SkeletonShimmer(
                      skeletonWidth: 120,
                      skeletonHeight: 30,
                      isLoading: _controller.isFetchingProfile,
                      widget: Obx(
                        () => Text(
                          _controller.lastName,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SkeletonShimmer(
                skeletonWidth: 120,
                skeletonHeight: 30,
                isLoading: _controller.isFetchingProfile,
                widget: Obx(
                  () => Text(
                    "(${_controller.username})",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
