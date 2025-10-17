resource "aws_iam_role" "foiye_backend_codebuild" {
	name	= "${var.app_name}-${var.app_env}-backend-codebuild-role"

	assume_role_policy	= <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
ROLE
}

resource "aws_iam_role_policy" "foiye_backend_codebuild" {
	name	= "${var.app_name}-${var.app_env}-backend-codebuild-policy"
	role	= aws_iam_role.foiye_backend_codebuild.name

	policy	= <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:*:*:${aws_cloudwatch_log_group.foiye.name}:*",
                "arn:aws:logs:*:*:${aws_cloudwatch_log_group.foiye.name}:*:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Action": [
                "s3:*",
                "ecr:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:*:*:*"
            ]
        }
    ]
}
POLICY
}

