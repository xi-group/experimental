resource "aws_lambda_function" "foiye_upload" {
	function_name	= "${var.app_name}-${var.app_env}-upload"

	s3_bucket	= "${aws_s3_bucket.foiye.id}"
	s3_key		= "${aws_s3_bucket_object.foiye_blank_lambda.key}"

	handler		= "index.handler"
	runtime		= "nodejs14.x"

        memory_size	= "${var.lambda_mem}"
        timeout		= "${var.lambda_timeout}"

	role		= "${aws_iam_role.foiye_upload_lambda.arn}"

	environment {
		variables	= {
			OKTA_URL	= "https://dev-83476926.okta.com/oauth2/default"
		}
	}
}

resource "aws_lambda_alias" "foiye_upload_alias" {
	name			= "current"
	description		= "current"
	function_name		= aws_lambda_function.foiye_upload.arn
	function_version	= "${aws_lambda_function.foiye_upload.version}"

	lifecycle {
		ignore_changes  = [function_version]
	}
}

resource "aws_lambda_permission" "foiye_upload" {
        statement_id    = "AllowExecutionFromAPIGateway"
        action          = "lambda:InvokeFunction"
        function_name   = aws_lambda_function.foiye_upload.function_name
        principal       = "apigateway.amazonaws.com"
        qualifier       = aws_lambda_alias.foiye_upload_alias.name

	source_arn	= "${aws_apigatewayv2_api.foiye.execution_arn}/*/*"
}
