provider "aws" {
  region = var.region
}

# =================================================
# VPC MODULE
# =================================================

module "vpc" {
  source = "./vpc"

  region        = var.region
  environment   = var.environment
  cluster_name  = var.cluster_name
  vpc_cidr      = var.vpc_cidr
  az_count      = var.az_count
}

# ==============================================
# EKS MODULE
# ==============================================

module "eks" {
  source = "./eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  depends_on = [module.vpc]
}

# =================================================
# IRSA MODULE
# =================================================

module "irsa" {
  source = "./iam"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider     = module.eks.oidc_provider

  depends_on = [module.eks]
}
