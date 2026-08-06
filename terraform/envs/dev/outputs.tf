output "vpc_id" { value = module.network.vpc_id }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
output "cluster_name"     { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "ecr_repository_url" { value = module.ecr}
output "lb_controller_role_arn" { value = module.lb_controller_irsa.iam_role_arn }
