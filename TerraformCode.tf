provider "aws" {
  region = "ap-south-1"
  profile = "anupreet"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
tags = {
    Name = "vpc"
  }
}

#Public subnet for WordPress instance
resource "aws_subnet" "public-subnet-for-wp" {
	vpc_id     = aws_vpc.vpc.id #Specifying VPC in which these subnets are to be created
	cidr_block = "192.168.1.0/24" #assigning IP range to the instances of  this subnet
	availability_zone = "ap-south-1a" #Specifying AZ
	map_public_ip_on_launch = true
	depends_on = [
  		aws_vpc.vpc,
   		]
	tags = {
    	Name = "public-subnet-for-wp" #Name for Reference
  		}
	}

#Private subnet for MySQL instance
resource "aws_subnet" "private-subnet-for-mysql" {
  	vpc_id     = aws_vpc.vpc.id
	  cidr_block = "192.168.2.0/24" #assigning IP range to the instances of  this subnet
	  availability_zone = "ap-south-1b" #Specifying AZ
	  depends_on = [
  		aws_vpc.vpc,
   		]
	  tags = {
    	Name = "private-subnet-for-mysql"  #Name for Reference
  		}
	}
	

#INTERNET GATEWAY FOR OUR SUBNET
resource "aws_internet_gateway" "internet-gateway" {
  	vpc_id = aws_vpc.vpc.id #to specify the VPC for this IG
	tags = {
    	Name = "internet-gateway" #Name for reference
  		}
}



#Creating Routing Table
resource "aws_route_table" "routing-table" {
  	vpc_id = aws_vpc.vpc.id #To specify the VPC for it
	route {
	    #To specify the Internet Gateway in which this table is to be attached
	    cidr_block = "0.0.0.0/0"
	    gateway_id = aws_internet_gateway.internet-gateway.id 
  		}
	depends_on = [
  		aws_internet_gateway.internet-gateway ,
   		]
	tags = {
    	Name = "routing-table"
  		}
}
#Associating Routing Table to The PUBLIC SUBNET ONLY
resource "aws_route_table_association" "routingtable-subnet" {
 	depends_on = [
    	aws_route_table.routing-table, #Specify the routing table 
 		]
	subnet_id      = aws_subnet.public-subnet-for-wp.id #Specify the Subnet 
  	route_table_id = aws_route_table.routing-table.id #Specify the routing table 
}


#Generating Key
resource "tls_private_key" "tls" {
  	algorithm   = "RSA"
}

#Specifying the access from key using SSH Protocol
resource "aws_key_pair" "tf-key" {
  	key_name   = "tf-key"
  	public_key =  tls_private_key.tls.public_key_openssh #To specify the TLS Private Key
	depends_on = [
	    tls_private_key.tlf,
	    aws_route_table_association.routingtable-subnet,
	  ]
	tags = {
	    Name = "access-key"
	  }


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
    


