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

variable "iac_repo_tag" {
  type        = string
  description = "Repository name (as AWS tag) on each resource to be created"
}

variable "iac_environment_tag" {
  type        = string
  description = "Environment name (as AWS tag) on each resource to be created"
}

variable "main_network_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "dummy_network_block" {
  type        = string
  description = "CIDR block for the dummy subnet"
}

variable "subnet_prefix_extension" {
  type        = number
  description = "CIDR block offset to be applied over VPC block for creating subnets"
}

variable "nat_gateway_instance_types" {
  type        = list(string)
  description = "EC2 instance types to be used as NAT Gateways"
}

variable "admin_users" {
  type        = list(string)
  description = "List of EKS administrator users"
}

variable "developer_users" {
  type        = list(string)
  description = "List of EKS developer users"
}

variable "developer_roles" {
  type        = list(map(list(string)))
  description = "List of developer users EKS roles"
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

variable "cluster_autoscaler_chart_version" {
  type        = string
  description = "Helm chart version for the cluster autoscaler"
}

# Spot termination handler
variable "spot_termination_handler_chart_name" {
  type        = string
  description = "Spot Termination Handler helm chart name"
}

variable "spot_termination_handler_chart_repo" {
  type        = string
  description = "Spot Termination Handler helm chart repo name"
}

variable "spot_termination_handler_chart_version" {
  type        = string
  description = "Spot Termination Handler helm chart version"
}

variable "spot_termination_handler_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to install Spot Termination Handler"
}

variable "ingress_gateway_chart_name" {
  type        = string
  description = "Ingress Gateway helm chart name"
}

variable "ingress_gateway_chart_repo" {
  type        = string
  description = "Ingress Gateway helm chart repo name"
}

variable "ingress_gateway_chart_version" {
  type        = string
  description = "Ingress Gateway helm chart version"
}

variable "ingress_gateway_annotations" {
  type        = map(string)
  description = "Ingress Gateway required annotations for EKS"
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

