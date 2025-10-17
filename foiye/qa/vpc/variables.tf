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
	default		= "qa"
}

variable "availability_zones" {
	description	= "VPC Availability Zones"
	type		= list(string)
	default		= ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
	description	= "VPC Public Subnets"
	type		= list(string)
	default		= ["172.21.101.0/24", "172.21.102.0/24"]
}

variable "private_subnets" {
	description	= "VPC Private Subnets"
	type		= list(string)
	default		= ["172.21.201.0/24", "172.21.202.0/24"]
}

