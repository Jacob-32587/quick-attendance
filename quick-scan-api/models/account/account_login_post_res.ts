import AccountGetModel from "./account_get_model.ts";

export interface AccountLoginPostRes {
  jwt: string;
  account: AccountGetModel;
}
