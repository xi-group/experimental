# RDS Subnet Group
resource "aws_db_subnet_group" "foiye" {
	name		= "${var.app_name}-${var.app_env}-dbsubnet"
	subnet_ids	= module.vpc.private_subnets

	tags = {
		Name	= "${var.app_name}-${var.app_env}-dbgroup"
	}
}

# RDS Security Group
resource "aws_security_group" "foiye_db" {
	name	= "${var.app_name}-${var.app_env}-db-sg"
	vpc_id	= module.vpc.vpc_id

	ingress {
		from_port		= 5432
		protocol		= "tcp"
		to_port			= 5432
		security_groups		= ["${aws_security_group.foiye_be_ecs_service.id}"]
	}

	egress {
		from_port		= 0
		protocol		= "-1"
		to_port			= 0
		cidr_blocks		= ["0.0.0.0/0"]
	}

	tags = {
		Name	= "${var.app_name}-${var.app_env}-db-sg"
	}
}

# RDS / PostgreSQL Instance
resource "aws_db_instance" "foiye" {
	allocated_storage		= 25
	backup_retention_period		= 3
	db_subnet_group_name		= "${aws_db_subnet_group.foiye.name}"
	engine				= "postgres"
	engine_version			= "13.3"
	identifier			= "${var.app_name}-${var.app_env}-db"
	instance_class			= "${var.db_instance_type}"
	multi_az			= false
	name				= "foiye"
	password			= "${trimspace(file("${path.module}/secrets/db-password.txt"))}"
	port				= 5432
	publicly_accessible		= true
	storage_encrypted		= true
	storage_type			= "gp2"
	username			= "foiye"
	vpc_security_group_ids		= ["${aws_security_group.foiye_db.id}"]
}

