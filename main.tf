provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "webserver" {
  ami           = "ami-04ff98ccbfa41c9ad"
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              # Update the system
              yum update -y

              # Install nginx
              amazon-linux-extras install nginx1.12 -y
              systemctl start nginx
              systemctl enable nginx

              # Create a basic "Hello World" HTML page
              echo "<html>
              <head><title>Hello World</title></head>
              <body><h1>Hello World</h1></body>
              </html>" > /usr/share/nginx/html/index.html

              # Ensure nginx starts on reboot
              chkconfig nginx on
              EOF

  tags = {
    Name = "webserver"
  }

  # Create a security group
  security_groups = [aws_security_group.webserver_sg.name]
}

resource "aws_security_group" "webserver_sg" {
  name        = "webserver-sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
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

output "webserver_url" {
  description = "URL of the webserver"
  value       = aws_instance.webserver.public_dns
}