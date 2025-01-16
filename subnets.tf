# Define Subnets
resource "aws_subnet" "subnet1" {
vpc_id = aws_vpc.main.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-1a"
tags = {
        Name = "Public-Subnet1"
    }
}

resource "aws_subnet" "subnet2" { 
vpc_id = aws_vpc.main.id 
cidr_block = "10.0.2.0/24" 
availability_zone = "us-east-1a" 
tags = { 
        Name = "Private-Subnet1"
    } 
} 
resource "aws_subnet" "subnet3" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1b"
    tags = { 
        Name = "Public-Subnet2"
    }
} 
resource "aws_subnet" "subnet4" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "Private-Subnet2"
    }
}