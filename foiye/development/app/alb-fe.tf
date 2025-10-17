resource "aws_security_group" "foiye_frontend" {
	name	= "${var.app_name}-${var.app_env}-frontend-alb-sg"
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
		Name	= "${var.app_name}-${var.app_env}-frontend-alb-sg"
	}
}

resource "aws_lb" "foiye_frontend" {
	name			= "${var.app_name}-${var.app_env}-frontend-alb"
	internal		= false
	load_balancer_type	= "application"
	security_groups		= ["${aws_security_group.foiye_frontend.id}"]
	subnets			= "${module.vpc.public_subnets}"

	access_logs {
		bucket	= aws_s3_bucket.foiye_alb_logs.bucket
		prefix	= "frontend"
		enabled	= true
	}
}

resource "aws_lb_target_group" "foiye_frontend" {
	name		= "${var.app_name}-${var.app_env}-frontend-tg"
	port		= 8080
	protocol	= "HTTP"
	vpc_id		= "${module.vpc.vpc_id}"
	target_type	= "ip"

	health_check {
		healthy_threshold	= 3
		unhealthy_threshold	= 10
		timeout			= 5
		interval		= 30
		path			= "/"
		port			= 8080
	}
}

resource "aws_lb_listener" "foiye_frontend_http" {
	load_balancer_arn	= aws_lb.foiye_frontend.arn
	port			= "80"
	protocol		= "HTTP"

	default_action {
		type	= "redirect"

		redirect {
			port		= "443"
			protocol	= "HTTPS"
			status_code	= "HTTP_301"
		}
	}
}

resource "aws_lb_listener" "foiye_frontend_https" {
	load_balancer_arn	= aws_lb.foiye_frontend.arn
	port			= "443"
	protocol		= "HTTPS"
	ssl_policy		= "ELBSecurityPolicy-2016-08"
	certificate_arn		= aws_acm_certificate.foiye.arn

	default_action {
		type			= "forward"
		target_group_arn	= aws_lb_target_group.foiye_frontend.arn
	}
}

resource "aws_lb_listener_rule" "foiye_frontend" {
	listener_arn = "${aws_lb_listener.foiye_frontend_https.arn}"

	action {
		type			= "forward"
		target_group_arn	= "${aws_lb_target_group.foiye_frontend.arn}"
	}

	condition {
		host_header {
			values	= ["foiye.com"]
		}
	}
}

