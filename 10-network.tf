# Setup up AZs
data "aws_availability_zones" "available_azs" {
  state = "available"
}

locals {
  availability_zones = slice(data.aws_availability_zones.available_azs.names, 0, var.vpc_azs)
}

# create VPC
resource "aws_vpc" "main_network" {
  cidr_block = var.main_network_block

  # Needed for private API endpoint access, according to https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html
  enable_dns_hostnames = true

  tags = {
    Name                                          = "${var.name_prefix}-main-network"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# get current aws Region
data "aws_region" "current_region" {}

# create one private Subnet for each AZ
resource "aws_subnet" "private_subnets" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.main_network.id
  cidr_block        = cidrsubnet(var.main_network_block, var.subnet_prefix_extension, count.index)
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name                              = "${var.name_prefix}-private-${local.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"

    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

