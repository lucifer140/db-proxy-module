locals {
  # TODO: Enter a unique name prefix to set for all resources created in your accounts, e.g., your org name.
  name_prefix = "proxy-test"
  # TODO: Enter the default AWS region, the same as where the terraform state S3 bucket is currently provisioned.
  default_region = "us-west-2"

  # TODO: Fill these in after applying the account-baseline-root to the root account.
  config_s3_bucket_name      = ""
  cloudtrail_s3_bucket_name  = ""
  cloudtrail_kms_key_arn     = ""

  # TODO: An accounts map to conveniently store all account IDs.
  # Centrally define all the AWS account IDs. We use JSON so that it can be readily parsed outside of Terraform.
  accounts = jsondecode(file("accounts.json"))
}