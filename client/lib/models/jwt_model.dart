import 'package:quick_attendance/models/base_api_model.dart';

class JwtModel extends BaseApiModel {
  String iss;
  String sub;
  String aud;
  String userId;
  int exp;
  int nbf;
  int iat;

  JwtModel({
    required this.iss,
    required this.sub,
    required this.aud,
    required this.userId,
    required this.exp,
    required this.nbf,
    required this.iat,
  });

  /// Throws a [FormatException]
  factory JwtModel.fromJson(Map<String, dynamic> json) {
    try {
      return JwtModel(
        iss: json["iss"],
        sub: json["sub"],
        aud: json["aud"],
        userId: json["user_id"],
        exp: json["exp"],
        nbf: json["nbf"],
        iat: json["iat"],
      );
    } catch (e) {
      throw FormatException("Failed to parse JWT payload");
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
