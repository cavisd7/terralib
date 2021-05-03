
/*module "shared_acc_trail" {
    source                  = "../global-modules/EnableAccountCloudTrail"

    trail_name              = "shared-acc-trail"
    dest_bucket_name        = var.org_trail_bucket_id
}*/

module "dev_vpc" {
    source                  = "../global-modules/PrivatePublicVPC"

    vpc_name                = var.vpc_name
    aws_region              = var.aws_region 
    cidr_block              = var.cidr_block 
    eks_cluster_name        = var.eks_cluster_name
}

module "eks_cluster" {
    source              = "../global-modules/EKSCluster"

    eks_cluster_name    = var.eks_cluster_name
    vpc_id              = module.dev_vpc.vpc_id
    subnet_ids          = module.dev_vpc.private_subnet_ids
}

module "eks_node_group" {
    source              = "../global-modules/EKSWorkerNode"

    cluster_name        = var.eks_cluster_name
    node_group_name     = var.eks_node_group_name
    vpc_id              = module.dev_vpc.vpc_id
    subnet_ids          = module.dev_vpc.private_subnet_ids
}