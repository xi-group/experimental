resource "aws_codestarconnections_connection" "foiye_upload" {
	name		= "${var.app_name}-${var.app_env}-cs-upload"
	provider_type	= "GitHub"
}

resource "aws_codepipeline" "foiye_upload" {
	name		= "${var.app_name}-${var.app_env}-codepipeline-upload"
	role_arn	= aws_iam_role.foiye_upload_codepipeline.arn

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
				ConnectionArn		= aws_codestarconnections_connection.foiye_upload.arn
				FullRepositoryId	= "Foiye/lambda-image-upload-authorizer"
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
				ProjectName	= aws_codebuild_project.foiye_upload.name
			}
		}
	}

	stage {
		name	= "Deploy"

		action {
			name		= "Deploy"
			category	= "Deploy"
			owner		= "AWS"
			provider	= "CodeDeploy"
			input_artifacts	= ["build_output"]
			version		= "1"

			configuration	= {
				ApplicationName		= aws_codedeploy_app.foiye_upload.name
				DeploymentGroupName	= aws_codedeploy_deployment_config.foiye_upload.id
			}
		}
	}
}
