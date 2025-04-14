import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class AccountSettingsModel implements BaseApiModel {
  late final RxBool prefersListView;

  AccountSettingsModel({bool prefersListView = false}) {
    this.prefersListView = true.obs;
  }

  factory AccountSettingsModel.fromJson(Map<String, dynamic> json) {
    return AccountSettingsModel(prefersListView: json["prefersListView"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'prefers_list_view': prefersListView.value};
  }
}
