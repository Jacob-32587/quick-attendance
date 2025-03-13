import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class GroupModel extends BaseApiModel<GroupModel> {
  /// uuid
  late final RxString groupId;
  late final RxString name;
  late final RxString description;
  late final RxString ownerUsername;

  /// uuid
  late final RxString ownerId;

  GroupModel({
    String groupId = "",
    String name = "",
    String description = "",
    String ownerUsername = "",
    String ownerId = "",
  }) {
    this.groupId = groupId.obs;
    this.name = name.obs;
    this.description = description.obs;
    this.ownerUsername = ownerUsername.obs;
    this.ownerId = ownerId.obs;
  }

  // Factory method to convert JSON to a Group object
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json["group_id"],
      name: json["name"],
      description: json["description"],
      ownerUsername: json["owner_username"],
      ownerId: json["ownerId"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "group_id": groupId.value,
      "name": name.value,
      "description": description.value,
      "owner_username": ownerUsername.value,
      "owner_id": ownerId.value,
    };
  }
}
