locals {
  common_tags = {
    Terraform   = "False"
    Environment = "${local.friendly_name_prefix}-test-standalone-external"
    Description = "Standalone Vault"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  region               = "us-west-2"
  friendly_name_prefix = random_string.friendly_name.id
  test_name            = "${local.friendly_name_prefix}-test-standalone-vault"
}