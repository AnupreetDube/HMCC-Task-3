#Generating Key
resource "tls_private_key" "tf-key" {
  	algorithm   = "RSA"
}

#Specifying the access from key using SSH Protocol
resource "aws_key_pair" "access-key" {
  	key_name   = "tf-key"
  	public_key =  tls_private_key.tf-key.public_key_openssh 
	depends_on = [
	    tls_private_key.tf-key,
	    aws_route_table_association.routingtable-subnet,
	  ]
	tags = {
	    Name = "access-key"
	  }
}
