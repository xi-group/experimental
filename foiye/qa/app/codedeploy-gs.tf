resource "aws_iam_role" "foiye_getsigned" {
	name	= "${var.app_name}-${var.app_env}-codedeploy-getsigned-role"

	assume_role_policy	= <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy_getsigned_AmazonS3FullAccess" {
	policy_arn	= "arn:aws:iam::aws:policy/AmazonS3FullAccess"
	role		= aws_iam_role.foiye_getsigned.name
}

resource "aws_iam_role_policy_attachment" "codedeploy_getsigned_AWSCodeDeployRoleForLambda" {
	policy_arn	= "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda"
	role		= aws_iam_role.foiye_getsigned.name
}

resource "aws_codedeploy_app" "foiye_getsigned" {
	compute_platform	= "Lambda"
	name			= "${var.app_name}-${var.app_env}-codedeploy-getsigned"
}

resource "aws_codedeploy_deployment_config" "foiye_getsigned" {
	deployment_config_name	= "${var.app_name}-${var.app_env}-codedeploy-config"
	compute_platform	= "Lambda"

	traffic_routing_config {
		type		= "TimeBasedLinear"

		time_based_linear {
			interval	= "${var.lambda_codedeploy_interval}"
			percentage	= "${var.lambda_codedeploy_percentage}"
		}
	}
}

resource "aws_codedeploy_deployment_group" "foiye_getsigned" {
	app_name		= aws_codedeploy_app.foiye_getsigned.name
	deployment_group_name	= "${var.app_name}-${var.app_env}-codedeploy-config"
	service_role_arn	= aws_iam_role.foiye_getsigned.arn
	deployment_config_name	= aws_codedeploy_deployment_config.foiye_getsigned.id

	deployment_style {
		deployment_option	= "WITH_TRAFFIC_CONTROL"
		deployment_type		= "BLUE_GREEN"
	}
}

