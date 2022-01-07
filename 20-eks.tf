# render Admin & Developer users list with the structure required by EKS module
locals {
  cluster_name = "${var.name_prefix}-eks"

  cluster_subnets = slice(aws_subnet.private_subnets, 0, var.autoscaling_azs)
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.0.1"

  cluster_name     = local.cluster_name
  cluster_version  = var.eks_cluster_version
  enable_irsa      = true

  vpc_id  = aws_vpc.main_network.id
  subnet_ids = local.cluster_subnets[*].id
}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
