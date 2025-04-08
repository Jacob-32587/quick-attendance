enum UserType {
  owner("Owner"),
  manager("Manager"),
  member("Member"),
  unknown("Unknown");

  final String value;
  const UserType(this.value);

  static UserType from(String? code) {
    return UserType.values.firstWhere(
      (e) => e.value == code,
      orElse: () => UserType.unknown,
    );
  }
}
