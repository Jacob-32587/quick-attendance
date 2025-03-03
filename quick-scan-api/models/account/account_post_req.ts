export interface AccountPostReq {
  username: string;
  email: string;
  first_name: string;
  last_name: string | null;
  password: string;
}
