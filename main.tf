provider "aws" {
  region = "us-east-1"
}

# Parámetros de entrada para VPC y Subnet
variable "vpc_id" {
  description = "ID de la VPC existente"
  type        = string
}

variable "subnet_id" {
  description = "ID de la Subnet existente"
  type        = string
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Permite tráfico HTTP y SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 23
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "apache_server" {
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 4
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.allow_http.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "¡Servidor Apache funcionando en EC2!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "ApacheServer"
  }

  key_name = "mi-par-claves" # cambia esto por el nombre real de tu key pair
}
