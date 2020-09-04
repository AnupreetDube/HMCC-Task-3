resource "aws_security_group" "mysql-secgrp" {
    depends_on = [
         aws_vpc.vpc,
         aws_subnet.private-subnet-for-mysql,
        ]
    name        = "mysql-secgrp"
    vpc_id      = aws_vpc.vpc.id
    description = "mysql security group"
    tags = {
        Name = "mysql-secgrp"
      }
#INBOUND RULES: only MYSQL Service Port
    ingress {
        description = "Mysql Port"
        from_port   = 3306 #Port for MYSQL Service
        to_port     = 3306
        protocol    = "tcp"
        #Allowing Incoming Traffic From Wordpress Security Groups too
        security_groups = [aws_security_group.wp-secgrp.id] 
      }
#OUTBOUND RULES
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    
    