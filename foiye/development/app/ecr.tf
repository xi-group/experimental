# Elastic Container Repository
resource "aws_ecr_repository" "foiye" {
	name			= "${var.app_name}-${var.app_env}-ecr"
	image_tag_mutability	= "MUTABLE"

	image_scanning_configuration {
		scan_on_push	= true
	}
}
