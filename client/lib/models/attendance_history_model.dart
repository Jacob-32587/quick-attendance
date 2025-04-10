import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class AttendanceHistoryModel
    extends BaseApiModel<AttendanceHistoryModel> {
  late final RxList<GroupData> attendance;

  AttendanceHistoryModel({List<GroupData>? attendance}) {
    this.attendance.addAll(attendance ?? []);
  }

  @override
  Map<String, dynamic> toJson() {
    // This object is not meant to be sent to the server
    // It is for viewing purposes only
    return {};
  }

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic>? json) {
    return AttendanceHistoryModel(
      attendance:
          (json?["attendance_records"] as List<dynamic>?)
              ?.map((x) => GroupData.fromJson(x))
              .toList(),
    );
  }
}

final class GroupData extends BaseApiModel<GroupData> {
  final groupId = RxnString();
  final groupName = RxnString();
  final attendanceRecords = RxList<AttendanceRecordData>();

  GroupData({
    String? groupId,
    String? groupName,
    List<AttendanceRecordData>? attendanceRecords,
  }) {
    this.groupId.value = groupId;
    this.groupName.value = groupName;
    this.attendanceRecords.addAll(attendanceRecords ?? []);
  }

  @override
  Map<String, dynamic> toJson() {
    // This object is not meant to be sent to the server
    // It is for viewing purposes only
    return {};
  }

  factory GroupData.fromJson(Map<String, dynamic>? json) {
    return GroupData(
      groupId: json?["group_id"],
      groupName: json?["group_name"],
      attendanceRecords:
          (json?["attendance_records"] as List<dynamic>?)
              ?.map((x) => AttendanceRecordData.fromJson(x))
              .toList(),
    );
  }
}

final class AttendanceRecordData extends BaseApiModel<AttendanceRecordData> {
  final attendanceId = RxnString();
  final attendanceTime = RxnString();
  final present = RxnBool();

  AttendanceRecordData({
    String? attendanceId,
    String? attendanceTime,
    bool? present,
  }) {
    this.attendanceId.value = attendanceId;
    this.attendanceTime.value = attendanceTime;
    this.present.value = present;
  }

  @override
  Map<String, dynamic> toJson() {
    // This object is not meant to be sent to the server
    // It is for viewing purposes only
    return {};
  }

  factory AttendanceRecordData.fromJson(Map<String, dynamic>? json) {
    return AttendanceRecordData(
      attendanceId: json?["attendance_id"],
      attendanceTime: json?["attendanceTime"],
      present: json?["present"],
    );
  }
}
