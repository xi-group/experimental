resource "aws_codebuild_project" "foiye_backend" {
	name		= "${var.app_name}-${var.app_env}-codebuild-backend"
	description	= "Foiye CodeBuild Backend Project"
	build_timeout	= "60"
	service_role	= aws_iam_role.foiye_backend_codebuild.arn

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
			name	= "ECR_URI"
			value	= aws_ecr_repository.foiye.repository_url
		}

		environment_variable {
			name	= "ARTIFACT_BUCKET"
			value	= aws_s3_bucket.foiye.id
		}
	}

	logs_config {
		cloudwatch_logs {
			group_name	= "${aws_cloudwatch_log_group.foiye.name}"
			stream_name	= "codebuild-backend"
		}

		s3_logs {
			status		= "ENABLED"
			location	= "${aws_s3_bucket.foiye.id}/backend-build-log"
		}
	}

	source {
		type	= "CODEPIPELINE"
	}

	source_version = "${var.app_branch}"
}

