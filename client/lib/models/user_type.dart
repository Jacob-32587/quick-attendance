enum UserType {
  owner("Owner"),
  manager("Manager"),
  member("Member"),
  unknown("Unknown");

  final String value;
  const UserType(this.value);

  static UserType from(String? value) {
    return UserType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserType.unknown,
    );
  }
}
