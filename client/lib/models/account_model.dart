import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class AccountModel extends BaseApiModel<AccountModel> {
  final String? accountId;

  late final RxString email;
  late final RxString username;
  late final RxString firstName;
  late final RxString lastName;

  AccountModel({
    this.accountId,
    String email = "",
    String username = "",
    String firstName = "",
    String lastName = "",
  }) {
    this.email = email.obs;
    this.username = username.obs;
    this.firstName = firstName.obs;
    this.lastName = lastName.obs;
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json["accountId"],
      email: json["email"],
      username: json["username"],
      firstName: json["first_name"],
      lastName: json["last_name"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "accountId": accountId,
      "email": email.value,
      "username": username.value,
      "first_name": firstName.value,
      "last_name": lastName.value,
    };
  }
}
