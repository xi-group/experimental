resource "aws_cloudwatch_log_group" "foiye" {
	name	= "${var.app_name}-${var.app_env}-logs"
}
