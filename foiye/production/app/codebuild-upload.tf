resource "aws_codebuild_project" "foiye_upload" {
	name		= "${var.app_name}-${var.app_env}-codebuild-upload"
	description	= "Foiye CodeBuild Upload Lambda Project"
	build_timeout	= "60"
	service_role	= aws_iam_role.foiye_upload_codebuild.arn

	artifacts {
		type	= "CODEPIPELINE"
	}

	cache {
		type		= "S3"
		location	= aws_s3_bucket.foiye.bucket
	}

	environment {
		compute_type			= "BUILD_GENERAL1_SMALL"
		image				= "aws/codebuild/standard:4.0"
		type				= "LINUX_CONTAINER"
		image_pull_credentials_type	= "CODEBUILD"
		privileged_mode			= "true"

		environment_variable {
			name	= "ARTIFACT_BUCKET"
			value	= aws_s3_bucket.foiye.id
		}

		environment_variable {
			name	= "FUNCTION_NAME"
			value	= aws_lambda_function.foiye_upload.function_name
		}
	}

	logs_config {
		cloudwatch_logs {
			group_name	= "${aws_cloudwatch_log_group.foiye.name}"
			stream_name	= "codebuild-upload"
		}

		s3_logs {
			status		= "ENABLED"
			location	= "${aws_s3_bucket.foiye.id}/upload-build-log"
		}
	}

	source {
		type	= "CODEPIPELINE"
	}

	source_version = "${var.app_branch}"
}

