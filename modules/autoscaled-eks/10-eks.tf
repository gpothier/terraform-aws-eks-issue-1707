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
}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

