variable "aws_region" {
	description	= "AWS Region"
	type		= string
	default		= "us-east-1"
}

variable "dns_zone" {
	description	= "DNS Zone"
	type		= string
	default		= "beta.foiye.com"
}

variable "app_name" {
	description	= "Application Name"
	type		= string
	default		= "foiye"
}

variable "app_env" {
	description	= "Application Environment (development/staging/production)"
	type		= string
	default		= "production"
}

variable "app_branch" {
	description	= "CodePipeline trigger branch"
	type		= string
	default		= "main"
}

variable "max_cpu_threshold" {
	description	= "Threshold for max CPU usage"
	default		= "65"
	type		= string
}

variable "min_cpu_threshold" {
	description	= "Threshold for min CPU usage"
	default		= "10"
	type		= string
}

variable "max_cpu_evaluation_period" {
	description	= "The number of periods over which data is compared to the specified threshold for max cpu metric alarm"
	default		= "3"
	type		= string
}

variable "min_cpu_evaluation_period" {
	description	= "The number of periods over which data is compared to the specified threshold for min cpu metric alarm"
	default		= "3"
	type		= string
}

variable "max_cpu_period" {
	description	= "The period in seconds over which the specified statistic is applied for max cpu metric alarm"
	default		= "60"
	type		= string
}
variable "min_cpu_period" {
	description	= "The period in seconds over which the specified statistic is applied for min cpu metric alarm"
	default		= "60"
	type		= string
}

variable "backend_scale_target_max_capacity" {
	description	= "The max capacity of the scalable target for backend"
	default		= 30
	type		= number
}

variable "backend_scale_target_min_capacity" {
	description	= "The min capacity of the scalable target for backend"
	default		= 3
	type		= number
}

variable "frontend_scale_target_max_capacity" {
	description	= "The max capacity of the scalable target for frontend"
	default		= 30
	type		= number
}

variable "frontend_scale_target_min_capacity" {
	description	= "The min capacity of the scalable target for frontend"
	default		= 3
	type		= number
}

variable "container_backend_cpu" {
	description	= "Backend Continaer CPU slots"
	default		= 1024
	type		= number
}

variable "container_backend_mem" {
	description	= "Backend Continaer Memory (MB)"
	default		= 4096
	type		= number
}

variable "container_frontend_cpu" {
	description	= "Frontend Continaer CPU slots"
	default		= 1024
	type		= number
}

variable "container_frontend_mem" {
	description	= "Frontend Continaer Memory (MB)"
	default		= 2048
	type		= number
}

variable "db_instance_type" {
	description	= "Postgre or Aurora Instance Type"
	default		= "db.r5.xlarge"
	type		= string
}

variable "db_instance_nodes" {
	description	= "Number of Aurora Instance Nodes"
	default		= 3
	type		= number
}

variable "lambda_mem" {
	description	= "Lambda Memory (MB)"
	default		= 256
	type		= number
}

variable "lambda_timeout" {
	description	= "Lambda acceptable exectuion timeout"
	default		= 30
	type		= number
}

variable "lambda_codedeploy_interval" {
	description	= "Lambda / CodeDeploy Interval (minutes)"
	default		= 1
	type		= number
}

variable "lambda_codedeploy_percentage" {
	description	= "Lambda / CodeDeploy Percentage change"
	default		= 25
	type		= number
}
