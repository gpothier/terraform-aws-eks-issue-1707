output "kubernetes_cluster_id" {
  value = module.eks_cluster.cluster_id
}

output "kubernetes_host" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "kubernetes_cluster_ca_certificate" {
  value = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

output "kubernetes_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}

output "kubernetes_cluster_security_groups" {
  value = [
    module.eks_cluster.worker_security_group_id,
    module.eks_cluster.cluster_primary_security_group_id,
    module.eks_cluster.cluster_security_group_id,
  ]
}
