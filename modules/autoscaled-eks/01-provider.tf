terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = ">= 2.0"
      configuration_aliases = [ kubernetes.eks ] # Alias to avoid accidentally inheriting default providers
    }
  }
}
