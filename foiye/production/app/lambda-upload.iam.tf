resource "aws_iam_role" "foiye_upload_lambda" {
	name			= "${var.app_name}-${var.app_env}-lambda-upload-role"

	assume_role_policy	= <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_upload_AmazonS3FullAccess" {
	policy_arn	= "arn:aws:iam::aws:policy/AmazonS3FullAccess"
	role		= aws_iam_role.foiye_upload_lambda.name
}

resource "aws_iam_role_policy_attachment" "lambda_upload_CloudWatchLogsFullAccess" {
	policy_arn	= "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
	role		= aws_iam_role.foiye_upload_lambda.name
}
