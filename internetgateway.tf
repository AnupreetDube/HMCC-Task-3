#INTERNET GATEWAY FOR OUR SUBNET
resource "aws_internet_gateway" "internet-gateway" {
  	vpc_id = aws_vpc.vpc.id #to specify the VPC for this IG
	tags = {
    	Name = "internet-gateway" #Name for reference
  		}
}
