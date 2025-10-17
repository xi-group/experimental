resource "aws_codestarconnections_connection" "foiye_frontend" {
	name		= "${var.app_name}-${var.app_env}-cs-frontend"
	provider_type	= "GitHub"
}

resource "aws_codepipeline" "foiye_frontend" {
	name		= "${var.app_name}-${var.app_env}-codepipeline-frontend"
	role_arn	= aws_iam_role.foiye_frontend_codepipeline.arn

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
				ConnectionArn		= aws_codestarconnections_connection.foiye_frontend.arn
				FullRepositoryId	= "Foiye/foiye-frontend"
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
				ProjectName	= aws_codebuild_project.foiye_frontend.name
			}
		}
	}

	stage {
		name	= "Approve"

		action {
			name			= "Approval"
			category		= "Approval"
			owner			= "AWS"
			provider		= "Manual"
			version			= "1"

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
				ServiceName	= aws_ecs_service.foiye_frontend.name
			}
		}
	}
}

resource "aws_codepipeline_webhook" "foiye_frontend" {
	name		= "${var.app_name}-${var.app_env}-codepipeline-frontend-webhook"
	authentication	= "UNAUTHENTICATED"
	target_action	= "Source"
	target_pipeline	= aws_codepipeline.foiye_frontend.name

	filter {
		json_path	= "$.ref"
		match_equals	= "refs/heads/{Branch}"
	}
}

