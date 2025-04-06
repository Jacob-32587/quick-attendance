import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';
import 'package:quick_attendance/models/user_type.dart';

final class PublicUserModel extends BaseApiModel<PublicUserModel> {
  late final RxnString userId = RxnString();
  late final RxString username;
  late final RxString firstName;
  late final RxnString lastName = RxnString();
  late final RxnString uniqueId = RxnString();
  late final Rxn<UserType> userType = Rxn<UserType>();

  PublicUserModel({
    String? userId,
    String? username = "",
    String? firstName = "",
    String? lastName = "",
    String? uniqueId = "",
    UserType? userType,
  }) {
    this.userId.value = userId;
    this.username = (username ?? "").obs;
    this.firstName = (firstName ?? "").obs;
    this.lastName.value = lastName;
    this.uniqueId.value = uniqueId;
    this.userType.value = userType;
  }

  @override
  Map<String, dynamic> toJson() {
    // This object is not meant to be sent to the server
    // It is for viewing purposes only
    return {};
  }

  factory PublicUserModel.fromJson(Map<String, dynamic>? json) {
    return PublicUserModel(
      userId: json?["user_id"],
      username: json?["username"],
      firstName: json?["first_name"],
      lastName: json?["last_name"],
      uniqueId: json?["unique_id"],
      userType: UserType.from(json?["user_type"]),
    );
  }
}
