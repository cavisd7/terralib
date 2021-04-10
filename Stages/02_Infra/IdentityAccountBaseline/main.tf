module "create_sec_groups" {
    count           = length(var.groups)
    source          = "./modules/sec-account-groups"

    name            = var.groups[count.index].group_name
    role_arns       = var.groups[count.index].iam_role_arns
}

module "create_sec_users" {
    count           = length(var.users)
    source          = "./modules/sec-account-users"

    name            = var.users[count.index].name
    groups          = var.users[count.index].groups
    pgp_key         = var.users[count.index].pgp_key

    depends_on      = [module.create_sec_groups]
}

/* Turn on CloudTrail on sec & identity account and deliver to s3 bucket in logs account */
resource "aws_cloudtrail" "sec_trail" {
    name                    = "sec-trail"
    s3_bucket_name          = var.org_trail_bucket_id
}