# create developers Role using RBAC
resource "kubernetes_cluster_role" "iam_roles_developers" {
  metadata {
    name = "${var.name_prefix}-developers"
  }

  dynamic "rule" {
    for_each = var.developer_roles
    content {
      api_groups = rule.value["api_groups"]
      resources  = rule.value["resources"]
      verbs      = rule.value["verbs"]
    }
  }

  depends_on = [module.main_cluster]
}

# bind developer Users with their Role
resource "kubernetes_cluster_role_binding" "iam_roles_developers" {
  metadata {
    name = "${var.name_prefix}-developers"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name_prefix}-developers"
  }

  dynamic "subject" {
    for_each = toset(var.developer_users)

    content {
      name      = subject.key
      kind      = "User"
      api_group = "rbac.authorization.k8s.io"
    }
  }

  depends_on = [module.main_cluster]
}
