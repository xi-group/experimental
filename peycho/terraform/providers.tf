terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = var.aws_region
  shared_config_files      = ["~/.aws/conig"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
}
