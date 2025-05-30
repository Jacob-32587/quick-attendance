import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

class GroupSettingsModel extends BaseApiModel {
  final promptMessage = RxnString();

  /// Defaults to 1, must be less than or equal to max
  late final RxInt minLength;

  /// Defaults to 64, must be greater than or equal to min
  late final RxInt maxLength;

  // Whether or not managers of a group receive the same unique id prompt as
  // members
  late final RxBool requireManagerId;

  GroupSettingsModel({
    String? promptMessage,
    int? minLength,
    int? maxLength,
    bool? requireManagerId,
  }) {
    this.promptMessage.value = promptMessage;
    this.minLength = (minLength ?? 1).obs;
    this.maxLength = (maxLength ?? 64).obs;
    this.requireManagerId = (requireManagerId ?? false).obs;
  }

  factory GroupSettingsModel.fromJson(Map<String, dynamic>? json) {
    return GroupSettingsModel(
      promptMessage: json?["prompt_message"],
      minLength: json?["min_length"],
      maxLength: json?["max_length"],
      requireManagerId: json?["required_for_managers"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "prompt_message": promptMessage.value,
      "min_length": minLength.value,
      "max_length": maxLength.value,
      "required_for_managers": requireManagerId.value,
    };
  }
}
