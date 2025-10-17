# Aurora/PSQL Subnet Group
resource "aws_db_subnet_group" "foiye" {
	name		= "${var.app_name}-${var.app_env}-dbsubnet"
	subnet_ids	= module.vpc.private_subnets

	tags = {
		Name	= "${var.app_name}-${var.app_env}-dbgroup"
	}
}

# Aurora/PSQL Security Group
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

# Aurora/PSQL Cluster
resource "aws_rds_cluster" "foiye" {
        cluster_identifier              = "${var.app_name}-${var.app_env}-db"
        database_name                   = "foiye"
        engine                          = "aurora-postgresql"
        engine_version                  = "13.3"
        master_username                 = "foiye"
        master_password                 = "${trimspace(file("${path.module}/secrets/db-password.txt"))}"
        backup_retention_period         = 7
        preferred_backup_window         = "04:00-05:00"
        preferred_maintenance_window    = "wed:08:00-wed:09:00"
        db_subnet_group_name            = "${aws_db_subnet_group.foiye.name}"
        final_snapshot_identifier       = "${var.app_name}-${var.app_env}-final"
        vpc_security_group_ids          = ["${aws_security_group.foiye_db.id}"]

        tags = {
                Name                    = "${var.app_name}-${var.app_env}-db"
        }

        lifecycle {
                create_before_destroy   = true
        }
}

# Aurora/PSQL Cluster Instances
resource "aws_rds_cluster_instance" "foiye_cluster_instance" {
        count                           = "${var.db_instance_nodes}"
        identifier                      = "${var.app_name}-${var.app_env}-db-${count.index}"
        cluster_identifier              = "${aws_rds_cluster.foiye.id}"
        instance_class                  = "${var.db_instance_type}"
        db_subnet_group_name            = "${aws_db_subnet_group.foiye.name}"
        publicly_accessible             = true
        engine                          = "aurora-postgresql"

        tags = {
                Name                    = "${var.app_name}-${var.app_env}-db-${count.index}"
        }

        lifecycle {
                create_before_destroy   = true
        }

}

