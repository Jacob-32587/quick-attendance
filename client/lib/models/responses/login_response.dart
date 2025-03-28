import 'package:quick_attendance/models/base_api_model.dart';

class LoginResponse extends BaseApiModel {
  String jwt;
  LoginResponse({required this.jwt});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(jwt: json["jwt"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"jwt": jwt};
  }
}
