### GLOBAL ###
name_prefix         = "terraform-issue-1707"
iac_environment_tag = "develop"
##############

### GLOBAL ###
iac_repo_tag = "ecaligrafix-infrastructure"
##############

### VPC ###
main_network_block         = "10.0.0.0/16"
dummy_network_block        = "10.0.254.0/24"
subnet_prefix_extension    = 4
nat_gateway_instance_types = ["t3.nano", "t2.nano", "t3.micro", "t2.micro"]
vpc_azs                    = 3
###########

### EKS ###
eks_cluster_version           = "1.21"
ingress_gateway_chart_name    = "ingress-nginx"
ingress_gateway_chart_repo    = "https://kubernetes.github.io/ingress-nginx"
ingress_gateway_chart_version = "3.29.0"
ingress_gateway_annotations = {
  "controller.service.targetPorts.http"  = "http",
  "controller.service.targetPorts.https" = "http",

  "controller.config.use-forwarded-headers" = "true"

  "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"        = "http",
  "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"               = "https",
  "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout" = "61",
  "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"                    = "elb",
}
spot_termination_handler_chart_name      = "aws-node-termination-handler"
spot_termination_handler_chart_repo      = "https://aws.github.io/eks-charts"
spot_termination_handler_chart_version   = "0.9.1"
spot_termination_handler_chart_namespace = "kube-system"
###########

### MAIN EKS CLUSTER ###
autoscaling_azs                      = 2
autoscaling_minimum_size_by_az       = 1
autoscaling_maximum_size_by_az       = 10
asg_instance_types                   = ["t3.medium", "t3.small"]
autoscaling_k8s_service_account_name = "cluster-autoscaler-aws-cluster-autoscaler"
cluster_autoscaler_chart_version     = "9.10.6"
###################

### DEPLOYMENTS ###
app_namespaces = [
  "develop"
]
###################


### IAM ###
admin_users = [
  "gpothier@caligrafix.cl",
  "gpothier",
  "admin",
  "k8s-pipelines"
]
developer_users = ["nobody"]
developer_roles = [
  {
    api_groups = ["*"]
    resources  = ["pods", "pods/log", "deployments", "services", "configmaps", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }
]
###########

