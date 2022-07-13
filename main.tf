data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_vpc" "this" {
  default = true
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.2"
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  vpc_id     = data.aws_vpc.this.id
  subnet_ids = data.aws_subnets.this.ids

  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    default_node_group = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1
    }
  }
}