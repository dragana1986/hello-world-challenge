module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  enable_cluster_creator_admin_permissions = true   # your IAM user = cluster admin
  cluster_endpoint_public_access           = true   # kubectl can reach the API from your laptop

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids                             # hint: nodes go in the PRIVATE subnets

  eks_managed_node_groups = {
    default = {
      instance_types = [var.instance_type]                    # hint: instance_type (t3.small)
      min_size       = var.min_size                     # hint: min_size (1 — always-on)
      max_size       = var.max_size                     # hint: max_size (4)
      desired_size   = var.desired_size                      # hint: desired_size (1)
    }
  }
}

