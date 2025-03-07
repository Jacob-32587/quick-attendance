class ExampleModel {
  final String? property;
  const ExampleModel({this.property});

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(property: json["property"]);
  }

  Map<String, dynamic> toJson() {
    return {"property": property};
  }
}
