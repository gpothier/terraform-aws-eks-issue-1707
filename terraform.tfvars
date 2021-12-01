name_prefix             = "terraform-issue-1707"
main_network_block      = "10.0.0.0/16"
subnet_prefix_extension = 4
vpc_azs                 = 3
eks_cluster_version     = "1.21"
autoscaling_azs         = 2 # Changing this value after apply causes the bug



