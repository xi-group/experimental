resource "aws_cloudfront_distribution" "foiye_images" {
	origin {
		domain_name			= "${aws_s3_bucket.foiye_image_upload.bucket_regional_domain_name}"
		origin_id			= "${aws_s3_bucket.foiye_image_upload.bucket}"

		custom_origin_config {
			http_port		= 80
			https_port		= 443
			origin_protocol_policy	= "match-viewer"
			origin_ssl_protocols	= ["TLSv1", "TLSv1.1", "TLSv1.2"]
		}
	}

	aliases = ["images.${data.aws_route53_zone.foiye.name}"]

	enabled			= true
	is_ipv6_enabled		= true

	logging_config {
		include_cookies	= false
		bucket		= "${aws_s3_bucket.foiye_alb_logs.bucket_regional_domain_name}"
		prefix		= "cloudfront-images"
	}

	default_cache_behavior {
		allowed_methods		= ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
		cached_methods		= ["GET", "HEAD"]
		target_origin_id	= "${aws_s3_bucket.foiye_image_upload.bucket}"

		forwarded_values {
			query_string	= false

			cookies {
				forward	= "none"
			}
		}

		viewer_protocol_policy	= "allow-all"
		min_ttl			= 0
		default_ttl		= 3600
		max_ttl			= 86400
	}

	price_class	= "PriceClass_100"

	restrictions {
		geo_restriction {
			restriction_type	= "none"
		}
	}

	viewer_certificate {
		acm_certificate_arn		= "${aws_acm_certificate.foiye.arn}"
		ssl_support_method		= "sni-only"
		minimum_protocol_version	= "TLSv1"
	}
}

