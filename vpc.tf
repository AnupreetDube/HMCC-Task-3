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
	