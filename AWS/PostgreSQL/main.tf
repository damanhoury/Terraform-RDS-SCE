provider "aws" {
  region = var.region
}

# Create the VPC

resource "aws_vpc" "SCE-VPC" {
  cidr_block           = var.main_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create Internet Gateway and attach it to VPC

resource "aws_internet_gateway" "SCE-IGW" {
  vpc_id = aws_vpc.SCE-VPC.id
}

# Create PUBLIC Subnets :

resource "aws_subnet" "SCE-SUBNET1" {
  vpc_id            = aws_vpc.SCE-VPC.id
  cidr_block        = var.public_subnet1
  availability_zone = var.availability_zone1
}

resource "aws_subnet" "SCE-SUBNET2" {
  vpc_id            = aws_vpc.SCE-VPC.id
  cidr_block        = var.public_subnet2
  availability_zone = var.availability_zone2
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

resource "aws_security_group" "SCE-POSTGRESQL-SG" {
  name        = "SCE-POSTGRESQL-SG"
  description = "Allow connection to POSTGRESQL port 5432"
  vpc_id      = aws_vpc.SCE-VPC.id

  ingress {
    description = "POSTGRESQL Port"
    from_port   = 5432
    to_port     = 5432
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

resource "aws_db_instance" "SCE-DEMO-POSTGRESQL" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.large"
  identifier             = "sce-demo-postgresql"
  username               = "postgres"
  password               = "ChangeMe1948"
  publicly_accessible    = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.SCE-DB-SUBNET-GROUP.name
  vpc_security_group_ids = ["${aws_security_group.SCE-POSTGRESQL-SG.id}"]
}

output "rds_endpoint" {
  value = aws_db_instance.SCE-DEMO-POSTGRESQL.endpoint
}