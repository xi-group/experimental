data "aws_route53_zone" "foiye" {
	name	= "${var.dns_zone}"
}

resource "aws_route53_record" "foiye_cert_validation" {
	for_each = {
		for dvo in aws_acm_certificate.foiye.domain_validation_options : dvo.domain_name => {
			name	= dvo.resource_record_name
			record	= dvo.resource_record_value
			type	= dvo.resource_record_type
		}
	}

	allow_overwrite	= true
	name		= each.value.name
	records		= [each.value.record]
	ttl		= 60
	type		= each.value.type
	zone_id		= data.aws_route53_zone.foiye.zone_id
}

resource "aws_route53_record" "foiye_frontend" {
	zone_id = data.aws_route53_zone.foiye.zone_id
	name    = "${data.aws_route53_zone.foiye.name}"
	type    = "A"

	alias {
		name                   = aws_lb.foiye_frontend.dns_name
		zone_id                = aws_lb.foiye_frontend.zone_id
		evaluate_target_health = true
	}
}

resource "aws_route53_record" "foiye_backend" {
	zone_id = data.aws_route53_zone.foiye.zone_id
	name    = "api.${data.aws_route53_zone.foiye.name}"
	type    = "CNAME"
	ttl     = "60"
	records = ["${aws_lb.foiye_backend.dns_name}"]
}

resource "aws_route53_record" "foiye_images" {
	zone_id = data.aws_route53_zone.foiye.zone_id
	name    = "images.${data.aws_route53_zone.foiye.name}"
	type    = "CNAME"
	ttl     = "60"
	records = ["${aws_cloudfront_distribution.foiye_images.domain_name}"]
}

resource "aws_route53_record" "foiye_image_upload" {
	name	= aws_apigatewayv2_domain_name.foiye.domain_name
	type	= "A"
	zone_id	= data.aws_route53_zone.foiye.zone_id

	alias {
		name                   = aws_apigatewayv2_domain_name.foiye.domain_name_configuration[0].target_domain_name
		zone_id                = aws_apigatewayv2_domain_name.foiye.domain_name_configuration[0].hosted_zone_id
		evaluate_target_health = false
	}
}

resource "aws_route53_record" "foiye_rds" {
	zone_id = data.aws_route53_zone.foiye.zone_id
	name    = "db.${data.aws_route53_zone.foiye.name}"
	type    = "CNAME"
	ttl     = "60"
	records = ["${aws_db_instance.foiye.address}"]
}

resource "aws_route53_record" "foiye_rds_reader_endpoint" {
	zone_id = data.aws_route53_zone.foiye.zone_id
	name    = "dbro.${data.aws_route53_zone.foiye.name}"
	type    = "CNAME"
	ttl     = "60"
	records = ["${aws_db_instance.foiye.address}"]
}
