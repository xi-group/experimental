variable "aws_region" {
	type		= string
	default		= "us-east-1"
}

variable "app_name" {
	type		= string
	default		= "foiye"
}

variable "app_env" {
	type		= string
	default		= "staging"
}

variable "availability_zones" {
	description	= "VPC Availability Zones"
	type		= list(string)
	default		= ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
	description	= "VPC Public Subnets"
	type		= list(string)
	default		= ["172.22.101.0/24", "172.22.102.0/24"]
}

variable "private_subnets" {
	description	= "VPC Private Subnets"
	type		= list(string)
	default		= ["172.22.201.0/24", "172.22.202.0/24"]
}

