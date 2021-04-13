module "create_sec_groups" {
    count           = length(var.groups)
    source          = "./modules/IdentityAccountGroups"

    name            = var.groups[count.index].group_name
    role_arns       = var.groups[count.index].iam_role_arns
}

module "create_sec_users" {
    count           = length(var.users)
    source          = "./modules/IdentityAccountUsers"

    name            = var.users[count.index].name
    groups          = var.users[count.index].groups
    pgp_key         = var.users[count.index].pgp_key

    depends_on      = [module.create_sec_groups]
}

/* 
 * Turn on CloudTrail on sec & identity account and deliver to s3 bucket in logs account 
 */

module "sec_trail" {
    source                  = "../global-modules/EnableAccountCloudTrail"

    trail_name              = "sec-trail"
    dest_bucket_name        = var.org_trail_bucket_id
}