import 'package:get/state_manager.dart';
import 'package:quick_attendance/models/base_api_model.dart';
import 'package:quick_attendance/models/public_user_model.dart';

/// Equivalent object to `AttendanceGroupGetData`
class GroupAttendanceViewModel extends BaseApiModel<GroupAttendanceViewModel> {
  final RxnString attendanceId = RxnString();
  final Rxn<DateTime> attendanceTime = Rxn<DateTime>();
  RxList<PublicUserModel>? attendees;

  GroupAttendanceViewModel({
    String? attendanceId,
    DateTime? attendanceTime,
    List<PublicUserModel>? attendees,
  }) {
    this.attendanceId.value = attendanceId;
    this.attendanceTime.value = attendanceTime;
    this.attendees = attendees != null ? RxList.from(attendees) : null;
  }

  factory GroupAttendanceViewModel.fromJson(Map<String, dynamic>? json) {
    return GroupAttendanceViewModel(
      attendanceId: json?["attendance_id"],
      attendanceTime: DateTime.tryParse(json?["attendance_time"]),
      attendees:
          (json?["users"] as List<dynamic>?)
              ?.map((x) => PublicUserModel.fromJson(x))
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // This model does not get sent to the server
    return {};
  }
}
