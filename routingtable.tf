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

