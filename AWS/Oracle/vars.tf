variable "region" {}
variable availability_zone1 {}
variable availability_zone2 {}
variable "main_vpc_cidr" {}

# at least 2 subnets MUST be created in a VPC , as per AWS requirement

variable "public_subnet1" {}
variable "public_subnet2" {}