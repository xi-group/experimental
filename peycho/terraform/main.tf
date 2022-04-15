# Create a VPC
resource "aws_vpc" "tf_experiment" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.prefix}-experiment"
    env     = "${var.prefix}-dev"
    service = "${var.prefix}-tests"
  }
}

# Create public subnet.
resource "aws_subnet" "tf_public_subnet" {
  vpc_id                  = aws_vpc.tf_experiment.id
  cidr_block              = var.pub_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_names

  depends_on = [aws_vpc.tf_experiment]

  tags = {
    Name    = "${var.prefix}-public-subnet"
    env     = "${var.prefix}-dev"
    service = "${var.prefix}-tests"
  }
}

# Create example internet gateway.
resource "aws_internet_gateway" "tf_igw_dev" {
  vpc_id = aws_vpc.tf_experiment.id

  tags = {
    Name    = "${var.prefix}-igw-dev"
    env     = "${var.prefix}-dev"
    service = "${var.prefix}-tests"
  }
}

# Create routing table
resource "aws_route_table" "tf_public_igw_route" {
  vpc_id = aws_vpc.tf_experiment.id

  tags = {
    Name    = "${var.prefix}-igw-route"
    env     = "${var.prefix}-dev"
    service = "${var.prefix}-tests"
  }
}

# Create routing
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.tf_public_igw_route.id
  destination_cidr_block = var.igw_pub_route
  gateway_id             = aws_internet_gateway.tf_igw_dev.id
  depends_on             = [aws_route_table.tf_public_igw_route]
}

# associate route table
resource "aws_route_table_association" "tf_public_assoc" {
  subnet_id      = aws_subnet.tf_public_subnet.id
  route_table_id = aws_route_table.tf_public_igw_route.id
  depends_on     = [aws_route_table.tf_public_igw_route]
}

# create simple security group
resource "aws_security_group" "tf_dev_sg" {
  name        = "${var.prefix}-sg"
  description = "Allow ssh traffic to my test security group."
  vpc_id      = aws_vpc.tf_experiment.id

  dynamic "ingress" {
    for_each = var.sg_ingress_settings
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.prefix}-sg"
    env     = "${var.prefix}-dev"
    service = "${var.prefix}-tests"
  }
}

resource "aws_key_pair" "peycho_test_key" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "tf_test_instance" {
  ami           = data.aws_ami.tf_server_ami.id
  instance_type = var.dev_instance_type

  key_name               = aws_key_pair.peycho_test_key.key_name
  vpc_security_group_ids = [aws_security_group.tf_dev_sg.id]
  subnet_id              = aws_subnet.tf_public_subnet.id

  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = var.ec2_resource_tags
}
