### GLOBAL ###
name_prefix         = "terraform-issue-1707"
iac_environment_tag = "develop"
##############

### GLOBAL ###
iac_repo_tag = "ecaligrafix-infrastructure"
##############

### VPC ###
main_network_block         = "10.0.0.0/16"
subnet_prefix_extension    = 4
nat_gateway_instance_types = ["t3.nano", "t2.nano", "t3.micro", "t2.micro"]
vpc_azs                    = 3
###########

### EKS ###
eks_cluster_version           = "1.21"
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

