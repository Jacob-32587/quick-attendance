import 'dart:convert';

import 'package:get/get_rx/get_rx.dart';
import 'package:quick_attendance/models/base_api_model.dart';
import 'package:quick_attendance/models/group_model.dart';

class GroupListResponseModel extends BaseApiModel {
  late final RxList<GroupModel> ownedGroups;
  late final RxList<GroupModel> managedGroups;
  late final RxList<GroupModel> memberGroups;
  GroupListResponseModel({
    List<GroupModel>? ownedGroups = const [],
    List<GroupModel>? managedGroups = const [],
    List<GroupModel>? memberGroups = const [],
  }) {
    this.ownedGroups = (ownedGroups ?? const []).obs;
    this.managedGroups = (managedGroups ?? const []).obs;
    this.memberGroups = (memberGroups ?? const []).obs;
  }

  factory GroupListResponseModel.fromJson(Map<String, dynamic> json) {
    return GroupListResponseModel(
      ownedGroups:
          (json["owned_groups"] as List<dynamic>)
              .map((x) => GroupModel.fromJson(x))
              .toList(),
      managedGroups:
          (json["managed_groups"] as List<dynamic>)
              .map((x) => GroupModel.fromJson(x))
              .toList(),
      memberGroups:
          (json["memeber_groups"] as List<dynamic>)
              .map((x) => GroupModel.fromJson(x))
              .toList(), // TODO: Fix typo when Jacob fixes his
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      // jsonEncode automatically attempts to call toJson()
      "owned_groups": jsonEncode(ownedGroups),
      "managed_groups": jsonEncode(managedGroups),
      "member_groups": jsonEncode(memberGroups),
    };
  }
}
