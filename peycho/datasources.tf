data "aws_ami" "tf_server_ami" {
  most_recent = true
  owners      = ["${var.image_owner}"]

  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
