resource "aws_acm_certificate" "foiye" {
	domain_name			= "${var.dns_zone}"
	subject_alternative_names	= ["*.${var.dns_zone}"]
	validation_method		= "DNS"
}

resource "aws_acm_certificate_validation" "foiye" {
	certificate_arn		= aws_acm_certificate.foiye.arn
	validation_record_fqdns	= [for record in aws_route53_record.foiye_cert_validation : record.fqdn]
}

