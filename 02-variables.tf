data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  namespaces = concat(var.app_namespaces, [var.ci_namespace])
}

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

variable "nat_gateway_instance_types" {
  type        = list(string)
  description = "EC2 instance types to be used as NAT Gateways"
}

variable "asg_instance_types" {
  type        = list(string)
  description = "EC2 instance types to be used as EKS Nodes"
}

variable "autoscaling_azs" {
  type        = number
  description = "Number of zones in which to deploye the main cluster"
}

variable "autoscaling_minimum_size_by_az" {
  type        = number
  description = "Minimum number of EC2 instances behind each EKS AZ"
}

variable "autoscaling_maximum_size_by_az" {
  type        = number
  description = "Maximum number of EC2 instances behind each EKS AZ"
}

variable "autoscaling_k8s_service_account_name" {
  type        = string
  description = "Name of the K8s service account in charge of scaling the cluster"
}

variable "eks_cluster_version" {
  type        = string
  description = "Kubernetes version for EKS clusters"
}

variable "app_namespaces" {
  type        = list(string)
  description = "List of Kubernetes namespaces for which a CouchDB server must be created"
}

variable "ci_namespace" {
  type        = string
  description = "Namespace for CI runners"
  default     = "ci"
}

