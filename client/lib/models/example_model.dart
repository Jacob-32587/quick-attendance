import 'package:get/get.dart';
import 'package:quick_attendance/models/base_api_model.dart';

final class ExampleModel extends BaseApiModel {
  // use late final on a private observable property
  // initialize it in the constructor body with a default value
  // create an equivalently named public GETTER for it because
  // late final without an initializer makes the initializer public
  // (because you declared it to be late)
  late final RxBool _exampleReactiveBool;
  RxBool get exampleReactiveBool => _exampleReactiveBool;

  // Generally always use final for non reactive fields.
  // Otherwise they will be mutable and non-reactive which means they can't
  // trigger a change to happen where they're referenced.
  final String? property;

  ExampleModel({this.property, exampleReactiveBool = true}) {
    _exampleReactiveBool = exampleReactiveBool.obs;
  }

  @override
  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(property: json["property"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"property": property};
  }
}
