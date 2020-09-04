#WORDPRESS INSTANCE
resource "aws_instance" "wordpress" {
      ami        = "ami-000cbce3e1b899ebd" #Image ID
      instance_type = "t2.micro" #Image Type
      key_name    = aws_key_pair.access-key.key_name # attach Key for SSH Access
      tags = {
          Name = "wp-instance"
        }
      subnet_id = aws_subnet.public-subnet-for-wp.id #Subnet for Instance Deploy
      vpc_security_group_ids = [aws_security_group.wp-secgrp.id] #attaching SG to Instance
    }


#MYSQL INSTANCE
resource "aws_instance" "mysql" {
      ami       = "ami-08706cb5f68222d09"
      instance_type = "t2.micro"
      key_name    = aws_key_pair.access-key.key_name
      tags = {
          Name = "mysql-instance"
        }
      subnet_id = aws_subnet.private-subnet-for-mysql.id #Subnet for Instance Deploy
      vpc_security_group_ids = [aws_security_group.mysql-secgrp.id] #attaching SG to Instance
    }