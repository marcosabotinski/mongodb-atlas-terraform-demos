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

resource "aws_route_table_association" "subnet-association-a" {
  subnet_id      = aws_subnet.primary-az1.id
  route_table_id = aws_vpc.primary.main_route_table_id
}

resource "aws_route_table_association" "subnet-association-b" {
  subnet_id      = aws_subnet.primary-az2.id
  route_table_id = aws_vpc.primary.main_route_table_id
}

resource "aws_route_table_association" "subnet-association-c" {
  subnet_id      = aws_subnet.primary-az3.id
  route_table_id = aws_vpc.primary.main_route_table_id
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

resource "aws_subnet" "primary-az3" {
    vpc_id                  = aws_vpc.primary.id
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "${var.aws_region}c" 
}

resource "aws_security_group" "primary_default" {
    name_prefix = "default-"
    description = "Default security group for all instances in ${aws_vpc.primary.id}"
    vpc_id      = aws_vpc.primary.id

    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }

    ingress {
        cidr_blocks = [
            aws_vpc.primary.cidr_block
        ]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }

    egress { 
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  
}


resource "aws_vpc_endpoint" "ptfe_service" {
  vpc_id             = aws_vpc.primary.id
  service_name       = mongodbatlas_private_endpoint.pl.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.primary-az1.id,aws_subnet.primary-az2.id,aws_subnet.primary-az3.id]
  security_group_ids = [aws_security_group.primary_default.id]
}


resource "aws_instance" "mongoclient" {
  ami             = "ami-0502e817a62226e03"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.primary-az1.id
  security_groups = [aws_security_group.primary_default.id]
  depends_on      = [mongodbatlas_cluster.cluster-test]
  key_name        = var.key_name

  provisioner "file" {
    source      = "../shared/insert.py"
    destination = "/tmp/insert.py"
  }

  provisioner "file" {
    source      = "../shared/requirements.txt"
    destination = "/tmp/requirements.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y python3-pip",
      "cd /tmp",
      "pip3 install -r requirements.txt",
      "python3 insert.py ${local.MONGOURI}",
    ]

  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = file(var.key_path)
    host        = self.public_ip
  }
}

locals { 
    MONGOURI = replace(lookup(mongodbatlas_cluster.cluster-test.connection_strings[0].aws_private_link_srv, aws_vpc_endpoint.ptfe_service.id), "mongodb+srv://", "mongodb+srv://${var.atlas_dbuser}:${var.atlas_dbpassword}@")
}