import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class AccountModel extends BaseApiModel<AccountModel> {
  final String? accountId;

  late final RxString _username;
  RxString get username => _username;

  late final RxString _firstName;
  RxString get firstName => _firstName;

  late final RxString _lastName;
  RxString get lastName => _lastName;

  AccountModel({
    this.accountId,
    String username = "",
    String firstName = "",
    String lastName = "",
  }) {
    _username = username.obs;
    _firstName = firstName.obs;
    _lastName = lastName.obs;
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json["accountId"],
      username: json["username"],
      firstName: json["firstName"],
      lastName: json["lastName"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {"accountId": accountId, "username": _username.value};
  }
}
