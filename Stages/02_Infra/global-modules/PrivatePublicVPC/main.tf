resource "aws_vpc" "vpc" {
    cidr_block      = var.cidr_block

    tags = {
        # Only needed for version 1.14 and earlier 
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
}

module "private_public_subnets" {
    source              = "./modules/PrivatePublicSubnet"

    subnet_count        = 2
    vpc_id              = aws_vpc.vpc.id
    vpc_cidr_block      = var.cidr_block
    eks_cluster_name    = var.eks_cluster_name
}