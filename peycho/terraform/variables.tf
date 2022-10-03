variable "prefix" {
  description = "Deployment prefix for aws resources."
  type        = string
  default     = "tf"
}

variable "aws_profile" {
  description = "AWS access profile"
  type        = string
  default     = "terraform"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "The IP address space for our VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "pub_subnet_cidr_block" {
  description = "The IP address space for our public subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "igw_pub_route" {
  description = "Destination route address for public subnets."
  type        = string
  default     = "0.0.0.0/0"
}

variable "image_name" {
  description = "The AMI name used for launching ec2 instance. Using most recent by adding wildcard in the end."
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
}

variable "image_owner" {
  description = "Owners of the AMI used for launching ec2 instance."
  type        = string
  default     = "099720109477"
}

variable "availability_zone_names" {
  description = "Default availability zone used for launching ec2 instance."
  type        = string
  default     = "eu-west-1a"
}

variable "dev_instance_type" {
  description = "Default instance type for launching ec2 instance."
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "SSH key name for accessing ec2 instances."
  type        = string
  default     = "tf-main-key"
}

variable "sg_ingress_settings" {
  description = "EC2 instance Security group rules"
  default = {
    "http ingress rule" = {
      "description" = "For HTTP access"
      "from_port"   = "80"
      "to_port"     = "80"
      "protocol"    = "tcp"
      "cidr_blocks" = ["212.50.83.22/32"]
    },
    "ssh ingress rule" = {
      "description" = "For SSH access"
      "from_port"   = "22"
      "to_port"     = "22"
      "protocol"    = "tcp"
      "cidr_blocks" = ["212.50.83.22/32"]
    }
  }

  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "ec2_resource_tags" {
  description = "Tags to set for ec2 resources"
  type        = map(string)
  default = {
    Name    = "tf-dev-instance",
    env     = "dev",
    service = "testing"
  }
}
