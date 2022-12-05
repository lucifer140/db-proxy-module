# -----------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# -----------------------------------------------------------------------------

locals {
 # common_vars  = read_terragrunt_config("${get_terragrunt_dir()}/common.hcl")
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  name_prefix    = local.common_vars.locals.name_prefix
  account        = local.account_vars.locals.domain_name.name
  account_name   = local.account_vars.locals.account_name
  account_id     = local.account_vars.locals.account_id
  default_region = local.common_vars.locals.default_region
 # aws_region     = local.region_vars["aws_region"]
  aws_region   = local.region_vars.locals.aws_region
  profile      = local.account_vars.locals.profile
}

# -----------------------------------------------------------------------------
# GENERATED PROVIDER BLOCK
# -----------------------------------------------------------------------------

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  profile = "${local.profile}"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

# -----------------------------------------------------------------------------
# GENERATED REMOTE STATE BLOCK
# -----------------------------------------------------------------------------

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    encrypt        = true
    bucket         = "${local.name_prefix}-${local.account_name}-${local.aws_region}-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    profile        = "${local.profile}"
    dynamodb_table = "terraform-locks"
  }
}

# -----------------------------------------------------------------------------
# GLOBAL PARAMETERS
# -----------------------------------------------------------------------------

inputs = {
  # Set commonly used inputs globally to keep child terragrunt.hcl files DRY
  aws_account_id = local.account_id
  aws_region     = local.aws_region
  name_prefix    = local.name_prefix
}
