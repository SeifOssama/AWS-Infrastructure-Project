# Creation of Elastic IP Address
resource "aws_eip" "nat_eip" {
tags = {
Name = "nat-eip"
}
}
# Creation of NATGATEWAY inside PublicSubnet2 [10.0.3.0]
resource "aws_nat_gateway" "nat_gw" {
allocation_id = aws_eip.nat_eip.id
subnet_id = aws_subnet.subnet3.id
tags = {
Name = "SEIF-NATGW"
}
}