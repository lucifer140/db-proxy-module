locals {
  account_name = "nonprod-accounts"
  profile = "nonprod"
  account_id = "366751107728"
  domain_name = {
    name = "nonprod-account"
    properties = {
      created_outside_terraform = true
    }
  }
}
