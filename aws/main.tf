# ***************************************
# VPC
# ***************************************
module "vpc" {
  source = "./modules/vpc"

  # AWS
  availability_zones = var.aws_availability_zones

  # VPC
  vpc_name                 = var.vpc_name
  vpc_cidr_block           = var.vpc_cidr_block
  vpc_enable_dns_support   = var.vpc_enable_dns_support
  vpc_enable_dns_hostnames = var.vpc_enable_dns_hostnames

  # Subnets
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # NGW
  single_nat_gateway = var.single_nat_gateway

  # Tags
  public_subnet_tags  = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
  vpc_tags            = var.vpc_tags
}

# ***************************************
# EKS
# ***************************************
module "eks" {
  source = "./modules/eks"

  # VPC
  vpc_id                 = module.vpc.vpc_id
  vpc_private_subnet_ids = module.vpc.private_subnets_ids

  # EKS
  eks_cluster_name                                = var.eks_cluster_name
  eks_cluster_version                             = var.eks_cluster_version
  eks_log_types                                   = var.eks_log_types
  eks_authentication_mode                         = var.eks_authentication_mode
  eks_bootstrap_cluster_creator_admin_permissions = var.eks_bootstrap_cluster_creator_admin_permissions
  eks_endpoint_private_access                     = var.eks_endpoint_private_access
  eks_endpoint_public_access                      = var.eks_endpoint_public_access
  eks_public_access_cidrs                         = var.eks_public_access_cidrs

  # EKS addons
  eks_addon_preserve                    = var.eks_addon_preserve
  eks_addon_resolve_conflicts_on_update = var.eks_addon_resolve_conflicts_on_update
  eks_vpc_cni_version                   = var.eks_vpc_cni_version
  eks_coredns_version                   = var.eks_coredns_version
  eks_kube_proxy_version                = var.eks_kube_proxy_version
  eks_ebs_csi_version                   = var.eks_ebs_csi_version

  # EKS KMS encryption
  kms_key_usage           = var.kms_key_usage
  kms_enable_key_rotation = var.kms_enable_key_rotation

  # EKS CloudWatch log retention
  cloudwatch_retention_in_days = var.cloudwatch_retention_in_days

  # EKS Node Group
  node_group_min_size                   = var.node_group_min_size
  node_group_max_size                   = var.node_group_max_size
  node_group_desired_size               = var.node_group_desired_size
  node_group_ami_type                   = var.node_group_ami_type
  node_group_capacity_type              = var.node_group_capacity_type
  node_group_disk_size                  = var.node_group_disk_size
  node_group_instance_types             = var.node_group_instance_types
  node_group_max_unavailable_percentage = var.node_group_max_unavailable_percentage

  # Tags
  eks_tags = var.eks_tags
}

# ***************************************
# KMS (for Ethereum keypair)
# ***************************************
module "kms_eth" {
  source = "./modules/kms_eth"

  # KMS config
  kms_eth_description              = var.kms_eth_description
  kms_eth_multi_region             = var.kms_eth_multi_region
  kms_eth_key_usage                = var.kms_eth_key_usage
  kms_eth_customer_master_key_spec = var.kms_eth_customer_master_key_spec
  kms_eth_alias_name               = var.kms_eth_alias_name

  # IAM
  eth_signer_service_account_namespace = var.eth_signer_service_account_namespace
  eth_signer_service_account_name      = var.eth_signer_service_account_name
  oidc_provider                        = module.eks.oidc_provider

  # Tags
  kms_eth_tags = var.kms_eth_tags
}

# ***************************************
# K8s deps
# ***************************************
module "k8s_deps" {
  source = "./modules/k8s_deps"

  aws_region        = var.aws_region
  vpc_id            = module.vpc.vpc_id
  whitelisted_cidrs = var.whitelisted_cidrs
  oidc_provider     = module.eks.oidc_provider
}
