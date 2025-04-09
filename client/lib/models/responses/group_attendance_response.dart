import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';
import 'package:quick_attendance/models/group_attendance_view_model.dart';

/// Equivalent object to `AttendanceGroupGetRes`
class GroupAttendanceResponse extends BaseApiModel<GroupAttendanceResponse> {
  RxList<GroupAttendanceViewModel>? attendance;
  GroupAttendanceResponse({List<GroupAttendanceViewModel>? attendance}) {
    this.attendance = attendance != null ? RxList.from(attendance) : null;
  }

  factory GroupAttendanceResponse.fromJson(Map<String, dynamic>? json) {
    return GroupAttendanceResponse(
      attendance:
          (json?["attendance"] as List<dynamic>?)
              ?.map((x) => GroupAttendanceViewModel.fromJson(x))
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
