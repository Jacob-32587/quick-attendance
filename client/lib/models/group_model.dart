import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class GroupModel extends BaseApiModel<GroupModel> {
  /// uuid
  final groupId = RxnString();
  final name = RxnString();
  final description = RxnString();
  final ownerUsername = RxnString();

  /// uuid
  final ownerId = RxnString();

  GroupModel({
    String? groupId = "",
    String? name = "",
    String? description = "",
    String? ownerUsername = "",
    String? ownerId = "",
  }) {
    this.groupId.value = groupId;
    this.name.value = name;
    this.description.value = description;
    this.ownerUsername.value = ownerUsername;
    this.ownerId.value = ownerId;
  }

  // Factory method to convert JSON to a Group object
  factory GroupModel.fromJson(Map<String, dynamic>? json) {
    return GroupModel(
      groupId: json?["group_id"],
      name: json?["group_name"],
      description: json?["group_description"],
      ownerUsername: json?["owner_username"],
      ownerId: json?["ownerId"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "group_id": groupId.value,
      "group_name": name.value,
      "group_description": description.value,
      "owner_username": ownerUsername.value,
      "owner_id": ownerId.value,
    };
  }
}
