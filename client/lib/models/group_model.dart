import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class GroupModel extends BaseApiModel<GroupModel> {
  final String? groupId;

  late final RxString _name;
  RxString get name => _name;

  late final RxString _description;
  RxString get description => _description;

  GroupModel({this.groupId, String name = "", String description = ""}) {
    _name = name.obs;
    _description = description.obs;
  }

  // Factory method to convert JSON to a Group object
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json["groupId"],
      name: json["name"],
      description: json["description"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "groupId": groupId,
      "name": name.value,
      "description": description.value,
    };
  }
}
