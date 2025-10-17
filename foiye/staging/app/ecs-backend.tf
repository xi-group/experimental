data "aws_ecs_task_definition" "foiye_backend" {
	task_definition	= aws_ecs_task_definition.foiye_backend.family
}

resource "aws_security_group" "foiye_be_ecs_service" {
	name	= "${var.app_name}-${var.app_env}-be-ecs-srv-sg"
	vpc_id	= "${module.vpc.vpc_id}"

	ingress {
		from_port	= 8080
		protocol	= "tcp"
		to_port		= 8080
		security_groups = ["${aws_security_group.foiye_backend.id}"]
	}

        egress {
		from_port       = 0
		protocol        = "-1"
		to_port         = 0
		cidr_blocks     = ["0.0.0.0/0"]
	}

	tags = {
		Name	= "${var.app_name}-${var.app_env}-be-ecs-srv-sg"
	}
}

resource "aws_ecs_service" "foiye_backend" {
	name            = "${var.app_name}-${var.app_env}-backend-service"
	cluster         = aws_ecs_cluster.foiye.arn

	# Track the latest ACTIVE revision
	task_definition	= "${aws_ecs_task_definition.foiye_backend.family}:${max(aws_ecs_task_definition.foiye_backend.revision, data.aws_ecs_task_definition.foiye_backend.revision)}"

	desired_count   = 1
	launch_type     = "FARGATE"

	load_balancer {
		target_group_arn	= aws_lb_target_group.foiye_backend.arn
		container_name		= "foiye-backend"
		container_port		= 8080
	}

	network_configuration {
		subnets			= "${module.vpc.public_subnets}"
		security_groups		= ["${aws_security_group.foiye_be_ecs_service.id}"]
		assign_public_ip	= "true"
	}

	lifecycle {
		ignore_changes	= [desired_count]
	}
}

resource "aws_ecs_task_definition" "foiye_backend" {
	family			= "${var.app_name}-${var.app_env}-backend"
	task_role_arn		= aws_iam_role.foiye_ecs_task_role.arn
	execution_role_arn	= aws_iam_role.foiye_ecs_task_exec_role.arn
	container_definitions	= <<TASK_DEFINITION
[
  {
    "name": "foiye-backend",
    "image": "${aws_ecr_repository.foiye.arn}/foiye-backend:latest",
    "cpu": ${var.container_backend_cpu},
    "memory": ${var.container_backend_mem},
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
	    "awslogs-group": "${aws_cloudwatch_log_group.foiye.name}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "backend"
        }
    }
  }
]
TASK_DEFINITION

	cpu				= "${var.container_backend_cpu}"
	memory				= "${var.container_backend_mem}"
	network_mode			= "awsvpc"
	requires_compatibilities	= ["FARGATE"]
}

