import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/pages/attendance_group/components/group_page.dart';

class GroupPageContainer extends StatelessWidget {
  late final GroupController _controller = Get.find();
  final backgroundImageUrl =
      'https://cdn.pixabay.com/photo/2016/06/02/02/33/triangles-1430105_1280.png';
  final Widget? content;
  final String title;

  GroupPageContainer({super.key, required this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          stretch: true,
          centerTitle: true,
          automaticallyImplyLeading: true,
          elevation: 4, // initial elevation
          actions: [
            Obx(
              () => IconButton(
                onPressed:
                    () =>
                        _controller.isEditingGroup.value =
                            !_controller.isEditingGroup.value,
                icon: Icon(
                  _controller.isEditingGroup.value ? Icons.save : Icons.edit,
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Image.network(backgroundImageUrl, fit: BoxFit.cover),
            titlePadding: EdgeInsets.only(bottom: 12, left: 70),
            expandedTitleScale: 1.5,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonShimmer(
                  isLoading: _controller.isLoadingGroup,
                  skeletonHeight: 35,
                  skeletonWidth: 300,
                  widget: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 24,
              left: 8,
              right: 8,
              bottom: 24,
            ),
            child: content,
          ),
        ),
      ],
    );
  }
}
