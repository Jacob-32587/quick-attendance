import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';
import 'package:quick_attendance/models/group_settings_model.dart';
import 'package:quick_attendance/models/public_user_model.dart';

final class GroupModel extends BaseApiModel<GroupModel> {
  /// uuid
  final groupId = RxnString();
  final owner = Rxn<PublicUserModel>();
  RxList<PublicUserModel>? managers = null;
  RxList<PublicUserModel>? members = null;
  RxList<PublicUserModel>? pendingMembers = null;
  final name = RxnString();
  final description = RxnString();
  final currentAttendanceId = RxnString();
  final eventCount = RxnInt();
  final settings = Rxn<GroupSettingsModel>();

  GroupModel({
    String? groupId = "",
    PublicUserModel? owner,
    List<PublicUserModel>? managers,
    List<PublicUserModel>? members,
    List<PublicUserModel>? pendingMembers,
    String? name = "",
    String? description = "",
    String? currentAttendanceId = "",
    int? eventCount = 0,
    GroupSettingsModel? groupSettings,
  }) {
    this.groupId.value = groupId;
    this.owner.value = owner;
    this.managers = managers != null ? RxList.from(managers) : null;
    this.members = members != null ? RxList.from(members) : null;
    this.pendingMembers =
        pendingMembers != null ? RxList.from(pendingMembers) : null;
    this.name.value = name;
    this.description.value = description;
    this.currentAttendanceId.value = currentAttendanceId;
    this.eventCount.value = eventCount;
    settings.value = groupSettings;
  }

  // Factory method to convert JSON to a Group object
  factory GroupModel.fromJson(Map<String, dynamic>? json) {
    return GroupModel(
      groupId: json?["group_id"],
      owner: PublicUserModel.fromJson(json?["owner"]),
      managers:
          (json?["managers"] as List<dynamic>?)
              ?.map((x) => PublicUserModel.fromJson(x))
              .toList(),
      members:
          (json?["members"] as List<dynamic>?)
              ?.map((x) => PublicUserModel.fromJson(x))
              .toList(),
      pendingMembers:
          (json?["pending_members"] as List<dynamic>?)
              ?.map((x) => PublicUserModel.fromJson(x))
              .toList(),
      name: json?["group_name"],
      description: json?["group_description"],
      currentAttendanceId: json?["current_attendance_id"],
      eventCount: json?["event_count"],
      groupSettings: GroupSettingsModel.fromJson(json?["unique_id_settings"]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "group_id": groupId.value,
      "group_name": name.value,
      "group_description": description.value,
      "current_attendance_id": currentAttendanceId.value,
    };
  }
}
