/* Create Organization */
resource "aws_organizations_organization" "org" {
    count                   = var.should_create_organization ? 1 : 0

    feature_set             = "ALL"

    aws_service_access_principals = [
        "cloudtrail.amazonaws.com",
        "config.amazonaws.com",
    ]
}

/* Create non-standalone child accounts under organization */
resource "aws_organizations_account" "child_accs" {
    count                   = length(var.child_accounts)

    name                    = var.child_accounts[count.index].name
    email                   = var.child_accounts[count.index].email

    depends_on              = [aws_organizations_organization.org]
}

/* For getting log account id after child accounts have been made */
data "aws_organizations_organization" "org_accounts" {
    depends_on              = [aws_organizations_account.child_accs]
}

/* Creates an s3 bucket where all account CloudTrail trails will deliver logs to. */
module "org_trail" {
    source                  = "./modules/organization-trail-provisions"
    /* TODO: For now the account designated for storing all CloudTrail logs must be named "logs" */
    log_acc_id              = data.aws_organizations_organization.org_accounts.non_master_accounts[index(data.aws_organizations_organization.org_accounts.non_master_accounts.*.name, "logs")].id
    org_trail_bucket_name   = var.org_trail_bucket_name
    child_accs_ids          = aws_organizations_account.child_accs.*.id
}

/* Turn on CloudTrail on root account and deliver to s3 bucket in logs account */
resource "aws_cloudtrail" "root_trail" {
    name                    = "root-trail"
    s3_bucket_name          = module.org_trail.org_trail_bucket_id
}

/* Create a group for admins on the root account. Caution: These users will have AdministratorAccess on the root account. 
 * Regular users will be created in the security & identity account.
 */
module "admin_group" {
    count                   = length(var.admin_users) > 0 ? 1 : 0
    source                  = "./modules/root-admin-group"
}

/* Create admin users and add to admin group */
/* TODO: test! */
/*module "root_users" {
    count                   = length(var.admin_users)
    source                  = "./modules/root-admin-user"

    name                    = var.admin_users[count.index].name
    pgp_key                 = var.admin_users[count.index].pgp_key
    admin_group_name        = module.admin_group.*.admin_group_name
}*/