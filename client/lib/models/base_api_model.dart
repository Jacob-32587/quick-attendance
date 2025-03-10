/// Encourages certain methods to exist on sub-classes
/// that are meant to interact with an API.
abstract class BaseApiModel<T> {
  const BaseApiModel();

  /// Should be implemented as a factory
  /// Dart makes it impossible to enforce the use of a factory
  T _fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
