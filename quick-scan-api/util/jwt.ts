import {
  JwtAlgorithmNotImplemented,
  JwtHeaderInvalid,
  JwtHeaderRequiresKid,
  JwtTokenExpired,
  JwtTokenInvalid,
  JwtTokenIssuedAt,
  JwtTokenNotBefore,
  JwtTokenSignatureMismatched,
} from "@hono/hono/utils/jwt/types";

/**
 * @description Check if a given value is an instance of any JWT exception
 * @param v - Value to check instance of any JWT exception
 * @returns True if the value is an instance of any JWT exception, false otherwise
 */
export function instanceOfJwtException(v: unknown): boolean {
  switch (v) {
    case v instanceof JwtHeaderInvalid:
      return true;
    case v instanceof JwtHeaderRequiresKid:
      return true;
    case v instanceof JwtTokenExpired:
      return true;
    case v instanceof JwtTokenInvalid:
      return true;
    case v instanceof JwtTokenIssuedAt:
      return true;
    case v instanceof JwtTokenNotBefore:
      return true;
    case v instanceof JwtTokenSignatureMismatched:
      return true;
    case v instanceof JwtAlgorithmNotImplemented:
      return true;
    default:
      return false;
  }
}
