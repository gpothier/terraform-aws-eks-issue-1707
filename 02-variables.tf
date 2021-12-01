data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

variable "vpc_azs" {
  type        = string
  description = "Number of availability zones to set up in the VPC"
}

variable "name_prefix" {
  type        = string
  description = "Prefix to name each resource to be created"
}

variable "main_network_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnet_prefix_extension" {
  type        = number
  description = "CIDR block offset to be applied over VPC block for creating subnets"
}

variable "autoscaling_azs" {
  type        = number
  description = "Number of zones in which to deploye the main cluster"
}

variable "eks_cluster_version" {
  type        = string
  description = "Kubernetes version for EKS clusters"
}
