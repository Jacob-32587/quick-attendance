import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_websocket.dart';
import 'package:quick_attendance/api/web_socket_service.dart';
import 'package:quick_attendance/components/shimmer_skeletons/skeleton_shimmer.dart';
import 'package:quick_attendance/pages/attendance_group/components/url_group_page.dart';

class GroupPageContainer extends StatelessWidget {
  late final GroupController _controller = Get.find();
  late final QuickAttendanceWebsocket _websocketService = Get.find();
  final backgroundImageUrl =
      'https://cdn.pixabay.com/photo/2016/06/02/02/33/triangles-1430105_1280.png';
  final Widget? content;
  final String title;

  Future<void> onRefresh() async {
    await _controller.fetchGroup(_controller.groupId);
  }

  void onLeaveGroupPage() {
    if (_websocketService.socketConnectionState.value ==
        SocketConnectionState.connected) {
      _websocketService.disconnect();
    }
    Get.toNamed("/"); // Navigate to home page
  }

  GroupPageContainer({super.key, required this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            centerTitle: true,
            automaticallyImplyLeading: true,
            elevation: 4, // initial elevation
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onLeaveGroupPage,
            ),
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
      ),
    );
  }
}
