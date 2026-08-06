module "network" {
  source = "../../modules/network"

  name            = var.name
  vpc_cidr        = var.vpc_cidr 
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets 
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.network.vpc_id              # from the network module
  private_subnet_ids = module.network.private_subnet_ids  # from the network module
  instance_type      = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
  desired_size       = var.desired_size
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = var.repository_name
}

module "lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "hello-world-lb-controller"
  attach_load_balancer_controller_policy = true   # hint: true — attaches AWS's ready-made policy

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn                    # hint: oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}