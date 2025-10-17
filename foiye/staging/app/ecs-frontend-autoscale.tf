resource "aws_cloudwatch_metric_alarm" "frontend_cpu_high" {
	alarm_name		= "${var.app_name}-${var.app_env}-frontend-cpu-high"
	comparison_operator	= "GreaterThanOrEqualToThreshold"
	evaluation_periods	= var.max_cpu_evaluation_period
	metric_name		= "CPUUtilization"
	namespace		= "AWS/ECS"
	period			= var.max_cpu_period
	statistic		= "Maximum"
	threshold		= var.max_cpu_threshold

	dimensions = {
		ClusterName	= aws_ecs_cluster.foiye.name
		ServiceName	= aws_ecs_service.foiye_frontend.name
	}

	alarm_actions	= [aws_appautoscaling_policy.frontend_scale_up_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_cpu_low" {
	alarm_name		= "${var.app_name}-${var.app_env}-frontend-cpu-low"
	comparison_operator	= "LessThanOrEqualToThreshold"
	evaluation_periods	= var.min_cpu_evaluation_period
	metric_name		= "CPUUtilization"
	namespace		= "AWS/ECS"
	period			= var.min_cpu_period
	statistic		= "Average"
	threshold		= var.min_cpu_threshold

	dimensions = {
		ClusterName	= aws_ecs_cluster.foiye.name
		ServiceName	= aws_ecs_service.foiye_frontend.name
	}

	alarm_actions	= [aws_appautoscaling_policy.frontend_scale_down_policy.arn]
}

resource "aws_appautoscaling_policy" "frontend_scale_up_policy" {
	name			= "${var.app_name}-${var.app_env}-frontnd-scale-up-policy"
	depends_on		= [aws_appautoscaling_target.frontend_scale_target]
	service_namespace	= aws_appautoscaling_target.frontend_scale_target.service_namespace
	resource_id		= aws_appautoscaling_target.frontend_scale_target.resource_id
	scalable_dimension	= aws_appautoscaling_target.frontend_scale_target.scalable_dimension

	step_scaling_policy_configuration {
		adjustment_type		= "ChangeInCapacity"
		cooldown		= 60
		metric_aggregation_type	= "Maximum"

		step_adjustment {
			metric_interval_lower_bound	= 0
			scaling_adjustment		= 1
		}
	}
}

resource "aws_appautoscaling_policy" "frontend_scale_down_policy" {
	name			= "${var.app_name}-${var.app_env}-frontnd-scale-down-policy"
	depends_on		= [aws_appautoscaling_target.frontend_scale_target]
	service_namespace	= aws_appautoscaling_target.frontend_scale_target.service_namespace
	resource_id		= aws_appautoscaling_target.frontend_scale_target.resource_id
	scalable_dimension	= aws_appautoscaling_target.frontend_scale_target.scalable_dimension

	step_scaling_policy_configuration {
		adjustment_type		= "ChangeInCapacity"
		cooldown		= 60
		metric_aggregation_type	= "Maximum"

		step_adjustment {
			metric_interval_upper_bound	= 0
			scaling_adjustment		= -1
		}
	}
}

resource "aws_appautoscaling_target" "frontend_scale_target" {
	service_namespace	= "ecs"
	resource_id		= "service/${aws_ecs_cluster.foiye.name}/${aws_ecs_service.foiye_frontend.name}"
	scalable_dimension	= "ecs:service:DesiredCount"
	min_capacity		= var.frontend_scale_target_min_capacity
	max_capacity		= var.frontend_scale_target_max_capacity
}
