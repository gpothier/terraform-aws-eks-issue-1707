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
    iac_repo                                      = var.iac_repo_tag
    iac_environment                               = var.iac_environment_tag
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
    iac_repo                          = var.iac_repo_tag
    iac_environment                   = var.iac_environment_tag
    "kubernetes.io/role/internal-elb" = "1"

    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# create one public Subnet for each AZ
resource "aws_subnet" "public_subnets" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.main_network.id
  cidr_block        = cidrsubnet(var.main_network_block, var.subnet_prefix_extension, count.index + 8)
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name                     = "${var.name_prefix}-public-${local.availability_zones[count.index]}"
    iac_repo                 = var.iac_repo_tag
    iac_environment          = var.iac_environment_tag
    "kubernetes.io/role/elb" = "1"

    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_network.id

  tags = {
    Name            = "${var.name_prefix}-igw"
    iac_repo        = var.iac_repo_tag
    iac_environment = var.iac_environment_tag
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main_network.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# create one NAT Gateway (using Spot instances) for each AZ
data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

resource "aws_security_group" "nat_gateway_sg" {
  name   = "${var.name_prefix}-nat-gateway-sg"
  vpc_id = aws_vpc.main_network.id

  dynamic "ingress" {
    for_each = concat(
      module.main_cluster.kubernetes_cluster_security_groups,
    )

    content {
      protocol        = "-1"
      from_port       = 0
      to_port         = 0
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name            = "${var.name_prefix}-nat-gateway-sg"
    iac_repo        = var.iac_repo_tag
    iac_environment = var.iac_environment_tag
  }
}

resource "aws_network_interface" "nat_gateway_nic" {
  count             = length(local.availability_zones)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  security_groups   = [aws_security_group.nat_gateway_sg.id]
  source_dest_check = false

  tags = {
    Name            = "${var.name_prefix}-nat-gateway-nic-${local.availability_zones[count.index]}"
    iac_repo        = var.iac_repo_tag
    iac_environment = var.iac_environment_tag
  }
}

resource "aws_eip" "nat_gateway_nic_eip" {
  count = length(local.availability_zones)
  vpc   = true

  tags = {
    Name            = "${var.name_prefix}-nat-gateway-eip-${local.availability_zones[count.index]}"
    iac_repo        = var.iac_repo_tag
    iac_environment = var.iac_environment_tag
  }
}

resource "aws_eip_association" "nat_gateway_nic_eip_association" {
  count                = length(local.availability_zones)
  network_interface_id = aws_network_interface.nat_gateway_nic[count.index].id
  allocation_id        = aws_eip.nat_gateway_nic_eip[count.index].id
}

resource "aws_launch_template" "nat_gateway_template" {
  count       = length(local.availability_zones)
  name_prefix = "${var.name_prefix}-nat-gateway-template-${local.availability_zones[count.index]}"
  image_id    = data.aws_ami.amazon_linux_ami.id
  user_data   = base64encode(file("${path.module}/definitions/nat-gateway-init.sh"))

  network_interfaces {
    network_interface_id = aws_network_interface.nat_gateway_nic[count.index].id
  }

  tags = {
    Name            = "${var.name_prefix}-nat-gateway-template-${local.availability_zones[count.index]}"
    iac_repo        = var.iac_repo_tag
    iac_environment = var.iac_environment_tag
  }
}

resource "aws_autoscaling_group" "nat_gateway" {
  count              = length(local.availability_zones)
  name_prefix        = "${var.name_prefix}-nat-gateway-${local.availability_zones[count.index]}"
  desired_capacity   = 1
  min_size           = 1
  max_size           = 1
  availability_zones = [local.availability_zones[count.index]]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.nat_gateway_template[count.index].id
        version            = "$Latest"
      }
      dynamic "override" {
        for_each = var.nat_gateway_instance_types
        content {
          instance_type = override.value
        }
      }
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-nat-gateway-${local.availability_zones[count.index]}"
    propagate_at_launch = true
  }

  tag {
    key                 = "iac_repo"
    value               = var.iac_repo_tag
    propagate_at_launch = true
  }

  tag {
    key                 = "iac_environment"
    value               = var.iac_environment_tag
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create one Route Table for each private subnet
resource "aws_route_table" "private_route_table" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.main_network.id

  tags = {
    Name            = "${var.name_prefix}-private-route-table-${local.availability_zones[count.index]}"
    iac_repo        = var.iac_repo_tag
    iac_environment = var.iac_environment_tag
  }
}

# associate route tables with private subnets
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(local.availability_zones)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

# define the actual routes
# We do not use inline routes in the route table because
# we want to ignore changes to instance_id (as the instance is not fixed
# but created by the ASG)
resource "aws_route" "private_route" {
  count = length(local.availability_zones)

  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_gateway_nic[count.index].id

  lifecycle {
    ignore_changes = [instance_id]
  }
}
