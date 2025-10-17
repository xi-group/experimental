resource "aws_apigatewayv2_api" "foiye" {
	name		= "${var.app_name}-${var.app_env}-apigw"
	protocol_type	= "HTTP"

	cors_configuration {
		allow_headers = ["*"]
		allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
		allow_origins = ["*"]
		expose_headers  = []
	}
}

resource "aws_apigatewayv2_stage" "foiye" {
	api_id		= aws_apigatewayv2_api.foiye.id

	name		= "${var.app_env}"
	auto_deploy	= true

	access_log_settings {
		destination_arn	= aws_cloudwatch_log_group.foiye.arn

		format		= jsonencode({
			requestId		= "$context.requestId"
			sourceIp		= "$context.identity.sourceIp"
			requestTime		= "$context.requestTime"
			protocol		= "$context.protocol"
			httpMethod		= "$context.httpMethod"
			resourcePath		= "$context.resourcePath"
			routeKey		= "$context.routeKey"
			status			= "$context.status"
			responseLength		= "$context.responseLength"
			integrationErrorMessage	= "$context.integrationErrorMessage"
		})
	}
}

resource "aws_apigatewayv2_integration" "foiye" {
	api_id			= aws_apigatewayv2_api.foiye.id

	integration_uri		= "${aws_lambda_alias.foiye_getsigned_alias.invoke_arn}"
	integration_type	= "AWS_PROXY"
	integration_method	= "POST"

	payload_format_version	= "2.0"
}

resource "aws_apigatewayv2_authorizer" "foiye" {
	api_id					= aws_apigatewayv2_api.foiye.id
	authorizer_type				= "REQUEST"
	authorizer_uri				= "${aws_lambda_alias.foiye_upload_alias.invoke_arn}"
	authorizer_payload_format_version	= "2.0"
	enable_simple_responses			= true
	identity_sources			= ["$request.header.Authorization"]
	name					= "${var.app_name}-${var.app_env}-apigw-authorizer"
}

resource "aws_apigatewayv2_route" "foiye_uploads" {
	api_id			= aws_apigatewayv2_api.foiye.id

	route_key		= "GET /uploads"
	authorization_type	= "CUSTOM"
	authorizer_id		= "${aws_apigatewayv2_authorizer.foiye.id}"
	target			= "integrations/${aws_apigatewayv2_integration.foiye.id}"
}

resource "aws_apigatewayv2_domain_name" "foiye" {
	domain_name	= "image-upload.${var.dns_zone}"

	domain_name_configuration {
		certificate_arn	= aws_acm_certificate.foiye.arn
		endpoint_type	= "REGIONAL"
		security_policy	= "TLS_1_2"
	}
}

resource "aws_apigatewayv2_api_mapping" "foiye" {
	api_id		= aws_apigatewayv2_api.foiye.id
	domain_name	= aws_apigatewayv2_domain_name.foiye.id
	stage		= aws_apigatewayv2_stage.foiye.id
}

output "image_service_api" {
	description	= "Deployment invoke url"
	value		= aws_apigatewayv2_stage.foiye.invoke_url
}
