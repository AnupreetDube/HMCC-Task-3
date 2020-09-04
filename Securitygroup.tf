resource "aws_security_group" "wp-secgrp" {
    depends_on = [
         aws_vpc.vpc,
         aws_subnet.public-subnet-for-wp,
        ]
    name        = "wp-secgrp"
    vpc_id      = aws_vpc.vpc.id
    description = "SSH-HTTP"
    tags = {
        Name = "wp-secgrp"
      }
#INBOUND RULES: SSH and HTTP Protocols
    ingress {
        description = "Ingress SSH"
        from_port   = 22 #Port for SSH
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ingress {
        description = "Ingress HTTP"
        from_port   = 80 #Port for Web Services
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
#OUTBOUND RULES
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    