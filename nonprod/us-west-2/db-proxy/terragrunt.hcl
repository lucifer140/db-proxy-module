terraform {
#  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
   source = "../../..//module/"
  # This module deploys some resources (e.g., AWS Config) across all AWS regions, each of which needs its own provider,
  # which in Terraform means a separate process. To avoid all these processes thrashing the CPU, which leads to network
  # connectivity issues, we limit the parallelism here.
  extra_arguments "parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=2"]
  }
}



include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load common variables shared across all accounts
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  # Extract the name prefix for easy access
  name_prefix = local.common_vars.locals.name_prefix

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract the account_name for easy access
  account_name = local.account_vars.locals.account_name

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the region for easy access
  aws_region = local.region_vars.locals.aws_region


  # A local for more convenient access to the accounts map.
  accounts = local.common_vars.locals.accounts

  # A local for convenient access to the security account root ARN.
}


inputs = {
      db-proxy-name = "proxy-test"
    policy-name = "policy-test"
    role-name = "test-role"
    sg-id = "Sg-0fa6202eca731f28d"
    debug_logging = "false"
    engine_family = "mysql"
    idle_client_timeout = "1800"
    require_tls = "true"
    connection_borrow_timeout = "120"
    max_connections_percent = "100"
    max_idle_connections_percent = "50"
    rds_cluster_identifier = "Hotel-non-prod-rds-cluster"
    vpc_subnet_ids = []







}
