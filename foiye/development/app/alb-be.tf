resource "aws_security_group" "foiye_backend" {
	name	= "${var.app_name}-${var.app_env}-backend-alb-sg"
	vpc_id	= "${module.vpc.vpc_id}"

	ingress {
		from_port	= 80
		protocol	= "tcp"
		to_port		= 80
		cidr_blocks	= ["0.0.0.0/0"]
	}

	ingress {
		from_port	= 443
		protocol	= "tcp"
		to_port		= 443
		cidr_blocks	= ["0.0.0.0/0"]
	}

	egress {
		from_port	= 0
		protocol	= "-1"
		to_port		= 0
		cidr_blocks	= ["0.0.0.0/0"]
	}

	tags = {
		Name	= "${var.app_name}-${var.app_env}-backend-alb-sg"
	}
}

resource "aws_lb" "foiye_backend" {
	name			= "${var.app_name}-${var.app_env}-backend-alb"
	internal		= false
	load_balancer_type	= "application"
	security_groups		= ["${aws_security_group.foiye_backend.id}"]
	subnets			= "${module.vpc.public_subnets}"

	access_logs {
		bucket	= aws_s3_bucket.foiye_alb_logs.bucket
		prefix  = "backend"
		enabled = true
	}
}

resource "aws_lb_target_group" "foiye_backend" {
	name		= "${var.app_name}-${var.app_env}-backend-tg"
	port		= 8080
	protocol	= "HTTP"
	vpc_id		= "${module.vpc.vpc_id}"
	target_type	= "ip"

	health_check {
		healthy_threshold	= 3
		unhealthy_threshold	= 10
		timeout			= 5
		interval		= 30
		path			= "/healthcheck"
		port			= 8080
	}
}

resource "aws_lb_listener" "foiye_backend_http" {
	load_balancer_arn	= aws_lb.foiye_backend.arn
	port			= "80"
	protocol		= "HTTP"

	default_action {
		type    = "redirect"

		redirect {
			port		= "443"
			protocol	= "HTTPS"
			status_code	= "HTTP_301"
		}
	}
}

resource "aws_lb_listener" "foiye_backend_https" {
	load_balancer_arn	= aws_lb.foiye_backend.arn
	port			= "443"
	protocol		= "HTTPS"
	ssl_policy		= "ELBSecurityPolicy-2016-08"
	certificate_arn		= aws_acm_certificate.foiye.arn

        default_action {
		type			= "forward"
		target_group_arn	= aws_lb_target_group.foiye_backend.arn
	}
}

# XXX: UNCOMENT TO ENABLE Drupal /admin/ restrictions on the ALB
# resource "aws_lb_listener_rule" "foiye_backend_admin_allow" {
# 	listener_arn	= "${aws_lb_listener.foiye_backend_https.arn}"
# 	priority	= 1
#
# 	action {
# 		type			= "forward"
# 		target_group_arn	= "${aws_lb_target_group.foiye_backend.arn}"
# 	}
#
# 	condition {
# 		path_pattern {
# 			values	= ["/admin/*"]
# 		}
# 	}
#
# 	condition {
# 		source_ip {
# 			values	= ["87.126.174.237/32", "181.30.10.90/32", "181.30.54.130/32"]
# 		}
# 	}
# }
#
# resource "aws_lb_listener_rule" "foiye_backend_admin_deny" {
# 	listener_arn	= "${aws_lb_listener.foiye_backend_https.arn}"
# 	priority	= 2
#
# 	action {
# 		type = "fixed-response"
#
# 		fixed_response {
# 			content_type	= "text/plain"
# 			message_body	= "Not Found"
# 			status_code	= "404"
# 		}
# 	}
#
# 	condition {
# 		path_pattern {
# 			values	= ["/admin/*"]
# 		}
# 	}
#
# 	condition {
# 		source_ip {
# 			values	= ["0.0.0.0/0"]
# 		}
# 	}
# }
