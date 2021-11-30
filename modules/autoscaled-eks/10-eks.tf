# render Admin & Developer users list with the structure required by EKS module
locals {
  admin_user_map_users = [
    for admin_user in var.admin_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"
      username = admin_user
      groups   = ["system:masters"]
    }
  ]

  developer_user_map_users = [
    for developer_user in var.developer_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${developer_user}"
      username = developer_user
      groups   = ["${var.cluster_name}-developers"]
    }
  ]
}

# create EKS cluster
module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  providers = {
    kubernetes = kubernetes.eks
    aws        = aws
  }

  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  write_kubeconfig = false
  enable_irsa      = true

  vpc_id  = var.aws_vpc_id
  subnets = flatten(var.aws_subnet_groups)

  cluster_endpoint_private_access = true

  # map developer & admin ARNs as kubernetes Users
  map_users = concat(local.admin_user_map_users, local.developer_user_map_users)
}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

