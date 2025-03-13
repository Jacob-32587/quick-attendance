export const enum UserType {
  Owner = "Owner",
  Manager = "Manager",
  Member = "Member",
}

export function is_privileged_user_type(
  user_type: UserType | null | undefined,
) {
  if (
    user_type === null || user_type === undefined ||
    user_type === UserType.Member
  ) return false;
  return true;
}
