import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class AccountSettingsModel implements BaseApiModel {
  late final RxBool _prefersListView;
  RxBool get prefersListView => _prefersListView;

  AccountSettingsModel({bool prefersListView = false}) {
    _prefersListView = prefersListView.obs;
  }

  factory AccountSettingsModel.fromJson(Map<String, dynamic> json) {
    return AccountSettingsModel(prefersListView: json["prefersListView"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'prefersListView': _prefersListView.value};
  }
}
