module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name    = local.name
  cluster_version = "1.33"

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    applications = {
      instance_types = ["m6i.large"]
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size = 2
      max_size = 5

      desired_size = 2

    },
    tools = {
      instance_types = ["m6i.large"]
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = 2
      max_size     = 5
      desired_size = 2
      taint = {
        key    = "tools"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    }
  }

  tags = local.tags

  depends_on = [module.vpc]
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "nginx" {
  source = "./nginx"

  nginx_install = true
}