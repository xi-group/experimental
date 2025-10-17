resource "aws_lambda_function" "foiye_getsigned" {
	function_name	= "${var.app_name}-${var.app_env}-getsigned"

	s3_bucket	= "${aws_s3_bucket.foiye.id}"
	s3_key		= "${aws_s3_bucket_object.foiye_blank_lambda.key}"

	handler		= "app.handler"
	runtime		= "nodejs14.x"

	memory_size	= "${var.lambda_mem}"
	timeout		= "${var.lambda_timeout}"

	role = "${aws_iam_role.foiye_getsigned_lambda.arn}"

	environment {
		variables	=	{
			UploadBucket	=	"${aws_s3_bucket.foiye_image_upload.bucket}"
		}
	}
}

resource "aws_lambda_alias" "foiye_getsigned_alias" {
	name			= "current"
	description		= "current"
	function_name		= aws_lambda_function.foiye_getsigned.arn
	function_version	= "${aws_lambda_function.foiye_getsigned.version}"

	lifecycle {
		ignore_changes  = [function_version]
	}
}

resource "aws_lambda_permission" "foiye_getsigned" {
	statement_id	= "AllowExecutionFromAPIGateway"
	action		= "lambda:InvokeFunction"
	function_name	= aws_lambda_function.foiye_getsigned.function_name
	principal	= "apigateway.amazonaws.com"
	qualifier	= aws_lambda_alias.foiye_getsigned_alias.name

	source_arn = "${aws_apigatewayv2_api.foiye.execution_arn}/*/*"
}
