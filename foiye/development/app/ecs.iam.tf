# IAM Role for ECS Task Deployment
resource "aws_iam_role" "foiye_ecs_task_exec_role" {
	name	= "${var.app_name}-${var.app_env}-task-exec-role"

	assume_role_policy	= <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
ROLE
}

# Standard association for task-exec role
resource "aws_iam_role_policy_attachment" "foiye_ecs_task_exec" {
	policy_arn	= "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
	role		= aws_iam_role.foiye_ecs_task_exec_role.name
}
resource "aws_iam_role_policy_attachment" "foiye_ecs_task_exec_logs" {
	policy_arn	= "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
	role		= aws_iam_role.foiye_ecs_task_exec_role.name
}

# IAM Role for ECS Task Runtime
resource "aws_iam_role" "foiye_ecs_task_role" {
	name	= "${var.app_name}-${var.app_env}-task-role"

	assume_role_policy	= <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
ROLE
}

# Access to cloudwatch Logs for task-runtime role
resource "aws_iam_role_policy_attachment" "foiye_ecs_task_cw" {
	policy_arn	= "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
	role		= aws_iam_role.foiye_ecs_task_role.name
}
