import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/pages/attendance_group/group_page.dart';

class GroupHomeScreen extends StatelessWidget {
  late final GroupController _controller = Get.find();

  GroupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoadingGroup.value ||
          (_controller.hasLoadedGroup.value &&
              _controller.group.value != null)) {
        return _GroupScreen(controller: _controller);
      } else {
        return _GroupNotFoundScreen();
      }
    });
  }
}

class _GroupScreen extends StatelessWidget {
  final GroupController controller;
  const _GroupScreen({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => BinaryChoice(
            choice: controller.isEditingGroup.value,
            widget1: _GroupEditScreen(controller: controller),
            widget2: _GroupDetailsScreen(controller: controller),
          ),
        ),
      ],
    );
  }
}

class _GroupNotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Group does not exist",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Get.offNamed("/");
          },
          child: Text("Back to Home"),
        ),
      ],
    );
  }
}

class _GroupDetailsScreen extends StatelessWidget {
  final GroupController controller;

  _GroupDetailsScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _ImageBackground(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonShimmer(
              isLoading: controller.isLoadingGroup,
              widget: SizedBox(
                width: double.infinity,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.group.value?.name.value ?? "",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Obx(
                          () => Text(
                            controller.group.value?.description.value ?? "",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupEditScreen extends StatelessWidget {
  final GroupController controller;

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  _GroupEditScreen({required this.controller}) {
    nameController = TextEditingController(
      text: controller.group.value?.name.value,
    );
    descriptionController = TextEditingController(
      text: controller.group.value?.description.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ImageBackground(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonShimmer(
              isLoading: controller.isLoadingGroup,
              widget: TextField(
                controller: nameController,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: "Group Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 8),
            SkeletonShimmer(
              isLoading: controller.isLoadingGroup,
              widget: TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Group Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(height: 1000, width: 10),
          ],
        ),
      ),
    );
  }
}

class _ImageBackground extends StatelessWidget {
  final ScrollController scrollController = ScrollController();
  final RxDouble parallaxOffset = 0.0.obs;
  final Widget child;

  _ImageBackground({required this.child}) {
    scrollController.addListener(() {
      parallaxOffset.value = scrollController.offset * 0.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        physics: BouncingScrollPhysics(),
        child: Stack(
          children: [
            /// Parallax effect on the picture background
            Obx(
              () => Transform.translate(
                offset: Offset(0, parallaxOffset.value),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Image.network(
                    'https://cdn.pixabay.com/photo/2016/06/02/02/33/triangles-1430105_1280.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Content of the page
            Column(
              children: [
                // Spacer so the page starts below the background image
                const SizedBox(height: 250),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(children: [SizedBox(height: 25), child]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
