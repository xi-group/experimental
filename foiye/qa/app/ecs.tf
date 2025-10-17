resource "aws_ecs_cluster" "foiye" {
	name			= "${var.app_name}-${var.app_env}-ecs"
	capacity_providers	= ["FARGATE"]

	setting {
		name	= "containerInsights"
		value	= "enabled"
	}
}
