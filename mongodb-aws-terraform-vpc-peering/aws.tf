provider "aws" {
  region = "eu-central-1"
  shared_credentials_file = "~/.aws"
}

resource "aws_vpc" "primary" { 
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
}

resource "aws_internet_gateway" "primary" {
    vpc_id               = aws_vpc.primary.id
}

resource "aws_route" "primary-internet_access" { 
    route_table_id         = aws_vpc.primary.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.primary.id 
}

resource "aws_route" "peeraccess" { 
    route_table_id            = aws_vpc.primary.main_route_table_id
    destination_cidr_block    = var.atlas_vpc_cidr
    vpc_peering_connection_id = mongodbatlas_network_peering.aws-atlas.connection_id
    depends_on                = [aws_vpc_peering_connection_accepter.peer]
}

resource "aws_subnet" "primary-az1" {
    vpc_id                  = aws_vpc.primary.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "${var.aws_region}a" 
}

resource "aws_subnet" "primary-az2" {
    vpc_id                  = aws_vpc.primary.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "${var.aws_region}b" 
}

resource "aws_security_group" "primary_default" {
    name_prefix = "default-"
    description = "Default security group for all instances in ${aws_vpc.primary.id}"
    vpc_id      = aws_vpc.primary.id
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = [
            aws_vpc.primary.cidr_block
        ]
    }

    egress { 
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  
}

resource "aws_vpc_peering_connection_accepter" "peer" {
    vpc_peering_connection_id = mongodbatlas_network_peering.aws-atlas.connection_id
    auto_accept               = true
}
