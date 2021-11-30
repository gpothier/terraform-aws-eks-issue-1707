data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

variable "iac_repo_tag" {
  type        = string
  description = "Repository name (as AWS tag) on each resource to be created"
}

variable "iac_environment_tag" {
  type        = string
  description = "Environment name (as AWS tag) on each resource to be created"
}

variable "cluster_version" {
  type = string
  description = "Kubernetes version for the cluster to create"
}

variable "vpc_cni_addon_version" {
  type        = string
  description = "Version of the VPC CNI Addon to install"
  default     = "v1.9.3-eksbuild.1"
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

variable "admin_users" {
  type        = list(string)
  description = "List of EKS administrator users"
}

variable "developer_users" {
  type        = list(string)
  description = "List of EKS developer users"
}

