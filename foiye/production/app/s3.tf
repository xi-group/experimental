data "aws_canonical_user_id" "current" {
}

resource "aws_s3_bucket" "foiye" {
	bucket	= "${var.app_name}-${var.app_env}-artifacts"
	acl	= "private"

	versioning {
		enabled	= true
	}
}

resource "aws_s3_bucket_object" "foiye_blank_lambda" {
	bucket	= aws_s3_bucket.foiye.id

	key	= "blank.zip"
	source	= "blank.zip"
}

resource "aws_s3_bucket" "foiye_image_upload" {
	bucket	= "${var.app_name}-${var.app_env}-image-upload"

	grant {
		id		= data.aws_canonical_user_id.current.id
		type		= "CanonicalUser"
		permissions	= ["FULL_CONTROL"]
	}

	grant {
		type		= "Group"
		permissions	= ["READ", "READ_ACP"]
		uri		= "http://acs.amazonaws.com/groups/global/AllUsers"
	}

	grant {
		type		= "Group"
		permissions	= ["READ", "READ_ACP"]
		uri		= "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
	}

	cors_rule {
			allowed_headers	= ["*"]
			allowed_methods	= ["GET", "PUT", "HEAD"]
			allowed_origins	= ["*"]
			expose_headers	= []
	}
}

resource "aws_s3_bucket_policy" "foiye_image_upload" {
	bucket	= aws_s3_bucket.foiye_image_upload.id

	policy	= jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.app_name}-${var.app_env}-image-upload/*"
        }
    ]
  })
}

resource "aws_s3_bucket" "foiye_alb_logs" {
	bucket		= "${var.app_name}-${var.app_env}-alb-logs"
	acl		= "log-delivery-write"
}

resource "aws_s3_bucket_policy" "foiye_alb_logs_policy" {
	bucket		= aws_s3_bucket.foiye_alb_logs.id
 	policy		= data.aws_iam_policy_document.foiye_alb_logs_policy.json
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "foiye_alb_logs_policy" {
	policy_id	= "${var.app_name}_${var.app_env}_alb_logs_policy"

	statement {
		actions		= ["s3:PutObject"]
		effect		= "Allow"
		resources	= ["${aws_s3_bucket.foiye_alb_logs.arn}/*"]
		principals {
			identifiers	= ["${data.aws_elb_service_account.main.arn}"]
			type		= "AWS"
		}
	}

	statement {
		actions		= ["s3:PutObject"]
		effect		= "Allow"
		resources	= ["${aws_s3_bucket.foiye_alb_logs.arn}/*"]
		principals {
			identifiers	= ["delivery.logs.amazonaws.com"]
			type		= "Service"
		}
	}

	statement {
		actions		= ["s3:GetBucketAcl"]
		effect		= "Allow"
		resources	= ["${aws_s3_bucket.foiye_alb_logs.arn}"]
		principals {
			identifiers	= ["delivery.logs.amazonaws.com"]
			type		= "Service"
		}
	}
}
