import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class GroupModel extends BaseApiModel<GroupModel> {
  final String? groupId;

  late final RxString name;
  late final RxString description;

  GroupModel({this.groupId, String name = "", String description = ""}) {
    this.name = name.obs;
    this.description = description.obs;
  }

  // Factory method to convert JSON to a Group object
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json["group_id"],
      name: json["name"],
      description: json["description"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "group_id": groupId,
      "name": name.value,
      "description": description.value,
    };
  }
}
