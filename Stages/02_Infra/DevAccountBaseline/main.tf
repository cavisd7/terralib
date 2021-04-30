
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