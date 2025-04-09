import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';
import 'package:quick_attendance/models/user_type.dart';

final class AttendanceHistoryModel
    extends BaseApiModel<AttendanceHistoryModel> {
  late final RxList<_GroupData> attendance;

  AttendanceHistoryModel({String? userId}) {
    this.userId.value = userId;
  }

  @override
  Map<String, dynamic> toJson() {
    // This object is not meant to be sent to the server
    // It is for viewing purposes only
    return {};
  }

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic>? json) {
    return AttendanceHistoryModel(userId: json?["user_id"]);
  }
}

final class _GroupData extends BaseApiModel<_GroupData> {
  final groupId = RxnString();
  final groupName = RxnString();
  late final attendanceRecords = RxList<_AttendanceRecordData>();

  _GroupData({String? groupId, String? groupName}) {
    this.groupId.value = groupId;
    this.groupName.value = groupName;
  }

  @override
  Map<String, dynamic> toJson() {
    // This object is not meant to be sent to the server
    // It is for viewing purposes only
    return {};
  }

  factory _GroupData.fromJson(Map<String, dynamic>? json) {
    return _GroupData(userId: json?["user_id"]);
  }
}

final class _AttendanceRecordData extends BaseApiModel<_AttendanceRecordData> {
  final attendanceId = RxnString();
  final attendanceTime = RxnString();
  final present = RxnBool();

  _AttendanceRecordData({
    String? attendanceId,
    String? attendanceTime,
    bool? present,
  }) {
    this.attendanceId.value = attendanceId;
    this.attendanceTime.value = attendanceTime;
    this.present.value = present;
  }
}
