import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class UserModel extends BaseApiModel<UserModel> {
  final String? userId;
  late final RxString email;
  late final RxString username;
  late final RxString firstName;
  late final RxString lastName;
  late final RxList<String> ownedGroupIds;
  late final RxList<String> managedGroupIds;
  late final RxList<String> memberGroupIds;
  late final RxList<String> pendingGroupIds;

  UserModel({
    this.userId,
    String? email = "",
    String? username = "",
    String? firstName = "",
    String? lastName = "",
    List<String>? ownedGroupIds = const [],
    List<String>? managedGroupIds = const [],
    List<String>? memberGroupIds = const [],
    List<String>? pendingGroupIds = const [],
  }) {
    this.email = (email ?? "").obs;
    this.username = (username ?? "").obs;
    this.firstName = (firstName ?? "").obs;
    this.lastName = (lastName ?? "").obs;
    this.ownedGroupIds = (ownedGroupIds ?? []).obs;
    this.managedGroupIds = (managedGroupIds ?? []).obs;
    this.memberGroupIds = (memberGroupIds ?? []).obs;
    this.pendingGroupIds = (pendingGroupIds ?? []).obs;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["accountId"],
      email: json["email"],
      username: json["username"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      ownedGroupIds: json["fk_owned_group_ids"],
      managedGroupIds: json["fk_managed_group_ids"],
      memberGroupIds: json["fk_member_group_ids"],
      pendingGroupIds: json["fk_pending_group_ids"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "accountId": userId,
      "email": email.value,
      "username": username.value,
      "first_name": firstName.value,
      "last_name": lastName.value,
      "fk_owned_group_ids": ownedGroupIds.toList(),
      "fk_managed_group_ids": managedGroupIds.toList(),
      "fk_member_group_ids": memberGroupIds.toList(),
      "fk_pending_group_ids": pendingGroupIds.toList(),
    };
  }
}
