import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:quick_attendance/models/base_api_model.dart';
import 'package:quick_attendance/models/pending_invite_jwt_model.dart';

final class UserModel extends BaseApiModel<UserModel> {
  late final RxnString userId;
  late final RxString email;
  late final RxString username;
  late final RxString firstName;
  late final RxString lastName;
  late RxList<PendingInviteJwtModel> pendingGroupJwts;

  UserModel({
    String? userId,
    String? email = "",
    String? username = "",
    String? firstName = "",
    String? lastName = "",
    List<PendingInviteJwtModel>? pendingGroupJwts,
  }) {
    this.email = (email ?? "").obs;
    this.username = (username ?? "").obs;
    this.firstName = (firstName ?? "").obs;
    this.lastName = (lastName ?? "").obs;
    this.userId = RxnString(userId);
    this.pendingGroupJwts =
        pendingGroupJwts != null ? RxList.from(pendingGroupJwts) : RxList();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["user_id"],
      email: json["email"],
      username: json["username"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      pendingGroupJwts:
          (json["fk_pending_group_ids"] as List<dynamic>?)
              ?.whereType<String>()
              .map((x) {
                try {
                  Map<String, dynamic> decodedJwt = Jwt.parseJwt(x);
                  return PendingInviteJwtModel.fromJson(decodedJwt, x);
                } catch (e) {
                  return null;
                }
              })
              .nonNulls
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "user_id": userId.value,
      "email": email.value,
      "username": username.value,
      "first_name": firstName.value,
      "last_name": lastName.value,
    };
  }
}
