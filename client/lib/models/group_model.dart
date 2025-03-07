class GroupModel {
  final int groupId;

  GroupModel({required this.groupId});

  // Factory method to convert JSON to a Group object
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(groupId: json["groupId"]);
  }

  Map<String, dynamic> toJson() {
    return {"groupId": groupId};
  }
}
