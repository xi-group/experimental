resource "aws_codestarconnections_connection" "foiye_backend" {
	name		= "${var.app_name}-${var.app_env}-cs-backend"
	provider_type	= "GitHub"
}

resource "aws_codepipeline" "foiye_backend" {
	name		= "${var.app_name}-${var.app_env}-codepipeline-backend"
	role_arn	= aws_iam_role.foiye_backend_codepipeline.arn

	artifact_store {
		location	= aws_s3_bucket.foiye.bucket
		type		= "S3"
	}

	stage {
		name	= "Source"

		action {
			name			= "Source"
			category		= "Source"
			owner			= "AWS"
			provider		= "CodeStarSourceConnection"
			version			= "1"
			output_artifacts	= ["source_output"]

			configuration = {
				ConnectionArn		= aws_codestarconnections_connection.foiye_backend.arn
				FullRepositoryId	= "Foiye/drupal-cms"
				BranchName		= "${var.app_branch}"
			}
		}
	}

	stage {
		name	= "Build"

		action {
			name			= "Build"
			category		= "Build"
			owner			= "AWS"
			provider		= "CodeBuild"
			input_artifacts		= ["source_output"]
			output_artifacts	= ["build_output"]
			version			= "1"

			configuration	= {
				ProjectName	= aws_codebuild_project.foiye_backend.name
			}
		}
	}

	stage {
		name	= "Deploy"

		action {
			name		= "Deploy"
			category	= "Deploy"
			owner		= "AWS"
			provider	= "ECS"
			input_artifacts	= ["build_output"]
			version		= "1"

			configuration	= {
				ClusterName	= aws_ecs_cluster.foiye.name
				ServiceName	= aws_ecs_service.foiye_backend.name
			}
		}
	}
}

resource "aws_codepipeline_webhook" "foiye_backend" {
	name		= "${var.app_name}-${var.app_env}-codepipeline-backend-webhook"
	authentication	= "UNAUTHENTICATED"
	target_action	= "Source"
	target_pipeline	= aws_codepipeline.foiye_backend.name

	filter {
		json_path	= "$.ref"
		match_equals	= "refs/heads/{Branch}"
	}
}

