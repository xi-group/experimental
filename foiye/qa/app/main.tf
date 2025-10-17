terraform {
	backend "s3" {
		bucket         = "foiye-tf-state"
		key            = "qa/terraform.tfstate"
		region         = "us-east-1"
		dynamodb_table = "foiye-tf-locks"
		encrypt        = true
	}
}

provider "aws" {
	region	= var.aws_region
}

module "vpc" {
	source	= "../vpc"
}

