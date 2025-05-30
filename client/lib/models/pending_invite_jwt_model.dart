import 'package:quick_attendance/models/base_api_model.dart';

class PendingInviteJwtModel extends BaseApiModel {
  String jwt;
  String iss;
  String sub;
  String aud;
  String userId;
  String groupName;
  bool isManagerInvite;
  UniqueIdSettingsModel? uniqueIdSettings;

  PendingInviteJwtModel({
    required this.iss,
    required this.sub,
    required this.aud,
    required this.userId,
    required this.jwt,
    required this.groupName,
    required this.isManagerInvite,
    required this.uniqueIdSettings,
  });

  factory PendingInviteJwtModel.fromJson(Map<String, dynamic> json, jwt) {
    return PendingInviteJwtModel(
      iss: json["iss"],
      sub: json["sub"],
      aud: json["aud"],
      userId: json["user_id"],
      jwt: jwt,
      groupName: json["group_name"],
      isManagerInvite: json["is_manager_invite"],
      uniqueIdSettings:
          json["unique_id_settings"] != null
              ? UniqueIdSettingsModel.fromJson(json["unique_id_settings"])
              : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class UniqueIdSettingsModel extends BaseApiModel {
  String? promptMessage;
  int? minLength;
  int? maxLength;
  bool? requiredForManager;

  UniqueIdSettingsModel({
    required this.promptMessage,
    required this.minLength,
    required this.maxLength,
    this.requiredForManager,
  });

  factory UniqueIdSettingsModel.fromJson(Map<String, dynamic>? json) {
    return UniqueIdSettingsModel(
      promptMessage: json?["prompt_message"],
      minLength: json?["min_length"],
      maxLength: json?["max_length"],
      requiredForManager: json?["required_for_manager"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
