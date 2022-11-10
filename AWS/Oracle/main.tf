provider "aws" {
  region = var.region
}

# Create the VPC

resource "aws_vpc" "SCE-VPC" {            
  cidr_block           = var.main_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "SCE-VPC"
  }
}

# Create Internet Gateway and attach it to VPC

resource "aws_internet_gateway" "SCE-IGW" {
  vpc_id = aws_vpc.SCE-VPC.id 
  tags = {
    Name = "SCE-IGW"
  }
}

# Create PUBLIC Subnets :

resource "aws_subnet" "SCE-SUBNET1" {
  vpc_id            = aws_vpc.SCE-VPC.id
  cidr_block        = var.public_subnet1
availability_zone = var.availability_zone1
  tags = {
    Name = "SCE-SUBNET1"
  }
}

resource "aws_subnet" "SCE-SUBNET2" {
  vpc_id            = aws_vpc.SCE-VPC.id
  cidr_block        = var.public_subnet2
  availability_zone = var.availability_zone2
  tags = {
    Name = "SCE-SUBNET2"
  }
}

# Create DB subnet group :

resource "aws_db_subnet_group" "SCE-DB-SUBNET-GROUP" {
  name       = "sce-db-subnet-group"
  subnet_ids = ["${aws_subnet.SCE-SUBNET1.id}", "${aws_subnet.SCE-SUBNET2.id}"]
}

#  Create Route table for Public Subnets :

resource "aws_route_table" "SCE-RT" {
  vpc_id = aws_vpc.SCE-VPC.id
  route {
    cidr_block = "0.0.0.0/0" # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.SCE-IGW.id
  }
}

# create Route table Association with Public Subnet's

resource "aws_route_table_association" "SCE-RT1-ASSOC" {
  subnet_id      = aws_subnet.SCE-SUBNET1.id
  route_table_id = aws_route_table.SCE-RT.id
}


resource "aws_route_table_association" "SCE-RT2-ASSOC" {
  subnet_id      = aws_subnet.SCE-SUBNET2.id
  route_table_id = aws_route_table.SCE-RT.id
}

# create security group :

resource "aws_security_group" "SCE-ORACLE-SG" {
  name        = "SCE-ORACLE-SG"
  description = "Allow connection to Oracle listener port 1597"
  vpc_id      = aws_vpc.SCE-VPC.id

  ingress {
    description = "ORACLE Listener"
    from_port   = 1597
    to_port     = 1597
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "SCE-DEMO-ORACLE" {

  engine                                = "oracle-ee"
  engine_version                        = "19.0.0.0.ru-2021-04.rur-2021-04.r1"
  instance_class                        = "db.t3.large"
  license_model                         = "bring-your-own-license"
  allocated_storage                     = 20
  max_allocated_storage                 = 50
  storage_encrypted                     = false
  identifier                            = "sce-oracle"
  db_subnet_group_name                  = aws_db_subnet_group.SCE-DB-SUBNET-GROUP.name
  name                                  = "orcl"
  username                              = "oraadmin"
  password                              = "ChangeMe194"
  port                                  = 1597
  enabled_cloudwatch_logs_exports       = ["alert", "audit"]
  backup_retention_period               = 0
  skip_final_snapshot                   = true
  deletion_protection                   = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  character_set_name                    = "AL32UTF8"
  publicly_accessible                   = true
  multi_az                              = false
  vpc_security_group_ids = [
    "${aws_security_group.SCE-ORACLE-SG.id}"
  ]
}

output "rds_endpoint" {
  value = aws_db_instance.SCE-DEMO-ORACLE.endpoint
}