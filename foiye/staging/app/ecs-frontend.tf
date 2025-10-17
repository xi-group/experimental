data "aws_ecs_task_definition" "foiye_frontend" {
	task_definition	= aws_ecs_task_definition.foiye_frontend.family
}

resource "aws_security_group" "foiye_fe_ecs_service" {
	name	= "${var.app_name}-${var.app_env}-fe-ecs-srv-sg"
	vpc_id	= "${module.vpc.vpc_id}"

	ingress {
		from_port	= 8080
		protocol	= "tcp"
		to_port		= 8080
		security_groups = ["${aws_security_group.foiye_frontend.id}"]
	}

        egress {
		from_port       = 0
		protocol        = "-1"
		to_port         = 0
		cidr_blocks     = ["0.0.0.0/0"]
	}

	tags = {
		Name	= "${var.app_name}-${var.app_env}-fe-ecs-srv-sg"
	}
}

resource "aws_ecs_service" "foiye_frontend" {
	name            = "${var.app_name}-${var.app_env}-frontend-service"
	cluster         = aws_ecs_cluster.foiye.arn

	# Track the latest ACTIVE revision
	task_definition	= "${aws_ecs_task_definition.foiye_frontend.family}:${max(aws_ecs_task_definition.foiye_frontend.revision, data.aws_ecs_task_definition.foiye_frontend.revision)}"

	desired_count   = 1
	launch_type     = "FARGATE"

	load_balancer {
		target_group_arn	= aws_lb_target_group.foiye_frontend.arn
		container_name		= "foiye-frontend"
		container_port		= 8080
	}

	network_configuration {
		subnets			= "${module.vpc.public_subnets}"
		security_groups		= ["${aws_security_group.foiye_fe_ecs_service.id}"]
		assign_public_ip	= "true"
	}

	lifecycle {
		ignore_changes	= [desired_count]
	}
}

resource "aws_ecs_task_definition" "foiye_frontend" {
	family			= "${var.app_name}-${var.app_env}-frontend"
	task_role_arn		= aws_iam_role.foiye_ecs_task_role.arn
	execution_role_arn	= aws_iam_role.foiye_ecs_task_exec_role.arn
	container_definitions	= <<TASK_DEFINITION
[
  {
    "name": "foiye-frontend",
    "image": "${aws_ecr_repository.foiye.arn}/foiye-frontend:latest",
    "cpu": ${var.container_frontend_cpu},
    "memory": ${var.container_frontend_mem},
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
            "awslogs-stream-prefix": "frontend"
        }
    }
  }
]
TASK_DEFINITION

	cpu				= "${var.container_frontend_cpu}"
	memory				= "${var.container_frontend_mem}"
	network_mode			= "awsvpc"
	requires_compatibilities	= ["FARGATE"]
}

