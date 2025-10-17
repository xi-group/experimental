resource "aws_cloudwatch_dashboard" "foiye" {
  dashboard_name = "${var.app_name}-${var.app_env}-Cloudwatch-Dashboard"

  dashboard_body = <<EOF
{
  "widgets": [
	{
	  "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "MemoryUtilized", "ServiceName", "${var.app_name}-${var.app_env}-frontend-service", "ClusterName", "${var.app_name}-${var.app_env}-ecs" ],
                    [ ".", "MemoryReserved", ".", ".", ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 30,
                "title": "ECS Frontend Memory Utilization"
            }
        },

{
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "MemoryReserved", "ServiceName", "${var.app_name}-${var.app_env}-backend-service", "ClusterName", "${var.app_name}-${var.app_env}-ecs" ],
                    [ ".", "MemoryUtilized", ".", ".", ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "title": "ECS Backend Memory Utilization",
                "period": 30,
                "stat": "Average"
            }
        },


 {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "CpuUtilized", "ServiceName", "${var.app_name}-${var.app_env}-frontend-service", "ClusterName", "${var.app_name}-${var.app_env}-ecs" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 60,
                "title": "ECS Frontend CPU Utilization"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "CpuUtilized", "ServiceName", "${var.app_name}-${var.app_env}-backend-service", "ClusterName", "${var.app_name}-${var.app_env}-ecs" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 60,
                "title": "ECS Backend CPU Utilization"
            }
        },

 {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.app_name}-${var.app_env}-frontend-alb" ]
                ],
                "region": "${var.aws_region}",
                "title": "ALB Frontend Requests"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.app_name}-${var.app_env}-backend-alb" ]
                ],
                "region": "${var.aws_region}",
                "title": "ALB Backend Requests"
            }
        },


        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${var.app_name}-${var.app_env}-frontend-tg", "LoadBalancer", "${var.app_name}-${var.app_env}-frontend-alb" ]
                ],
                "region": "${var.aws_region}",
                "title": "Frontend Healthy Host Count"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
		    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${var.app_name}-${var.app_env}-backend-tg", "LoadBalancer", "${var.app_name}-${var.app_env}-backend-alb" ]
                ],
                "region": "${var.aws_region}",
                "title": "Backend Healthy Host Count"
            }
        },

 {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", "${var.app_name}-${var.app_env}-frontend-tg", "LoadBalancer", "${var.app_name}-${var.app_env}-frontend-alb" ]   
                ],
                "region": "${var.aws_region}",
                "title": "Frontend Unhealthy Host Count"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
		    [ "AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", "${var.app_name}-${var.app_env}-backend-tg", "LoadBalancer", "${var.app_name}-${var.app_env}-backend-alb" ]           
                ],
                "region": "${var.aws_region}",
                "title": "Backend Unhealthy Host Count"
            }
        },


   {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${var.app_env}-${var.app_name}-frontend-tg", "LoadBalancer", "${var.app_env}-${var.app_name}-frontend-alb" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "title": "ALB Frontend Target Response Time"
            }
        },


{
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${var.app_name}-${var.app_env}-backend-tg", "LoadBalancer", "${var.app_name}-${var.app_env}-backend-alb" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "title": "ALB Backend Target Response Time",
                "period": 300,
                "stat": "Average"
            }
        }
      ]
}
EOF
}

