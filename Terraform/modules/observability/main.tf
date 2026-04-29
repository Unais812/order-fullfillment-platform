resource "aws_iam_role" "observability_role" {
  name = "observability-prometheus-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

# iam policy for prometheus to pull metrics from cloud watch 
resource "aws_iam_role_policy_attachment" "cw_read" {
  role       = aws_iam_role.observability_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_instance_profile" "observability_profile" {
  role = aws_iam_role.observability_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "observability" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.observability_sg.id]

# a container for an IAM role that allows you to securely pass role permissions to an Amazon EC2 instance at launch
  iam_instance_profile = aws_iam_instance_profile.observability_profile.name

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "observability-node"
  }
}

resource "aws_security_group" "observability_sg" {
  name        = "observability-stack-sg"
  description = "Observability stack access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}