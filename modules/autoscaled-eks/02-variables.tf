data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

variable "cluster_version" {
  type = string
  description = "Kubernetes version for the cluster to create"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster and other resources to create"
}

variable "aws_subnet_groups" {
  type        = list(list(string))
  description = "The AWS subnets to use for this cluster. A managed node group is created for each subnet group."
}

variable "aws_vpc_id" {
  type        = string
  description = "ID of the AWS VPC to use for this cluster"
}

