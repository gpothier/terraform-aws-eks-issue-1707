# render Admin & Developer users list with the structure required by EKS module
locals {
  cluster_name = "${var.name_prefix}-eks"

  cluster_subnets = slice(aws_subnet.private_subnets, 0, var.autoscaling_azs)
}


# Set up EKS cluster
module "main_cluster" {
  source = "./modules/autoscaled-eks"

  providers = {
    kubernetes.eks = kubernetes
    helm.eks       = helm
    aws            = aws
  }

  iac_repo_tag        = var.iac_repo_tag
  iac_environment_tag = var.iac_environment_tag

  cluster_version = var.eks_cluster_version

  cluster_name = local.cluster_name

  aws_vpc_id        = aws_vpc.main_network.id
  aws_subnet_groups = [for subnet in local.cluster_subnets[*].id : [subnet]]

  admin_users     = var.admin_users
  developer_users = var.developer_users
}

# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
  host                   = module.main_cluster.kubernetes_host
  cluster_ca_certificate = module.main_cluster.kubernetes_cluster_ca_certificate
  token                  = module.main_cluster.kubernetes_token
}

provider "helm" {
  kubernetes {
    host                   = module.main_cluster.kubernetes_host
    cluster_ca_certificate = module.main_cluster.kubernetes_cluster_ca_certificate
    token                  = module.main_cluster.kubernetes_token
  }
}

