# Create EC2 Instances
resource "aws_instance" "Bastion Host" {
ami = "ami-0182f373e66f89c85 "
instance_type = "t2.micro"
subnet_id = aws_subnet.subnet1.id
vpc_security_group_ids = [aws_security_group.SEIF-SG.id]
associate_public_ip_address = true
key_name = "key"
tags = {
Name = "Bastion Host"
}
}