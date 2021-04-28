/* 
 * Create Organization 
 */

resource "aws_organizations_organization" "org" {
    feature_set                     = "ALL"

    aws_service_access_principals   = var.org_service_access_principals
}

/* 
 * Create non-standalone child accounts under organization 
 */

resource "aws_organizations_account" "child_accs" {
    count                   = length(var.child_accounts)

    name                    = var.child_accounts[count.index].name
    email                   = var.child_accounts[count.index].email

    depends_on              = [aws_organizations_organization.org]
}

/* 
 * For getting log account id after child accounts have been made 
 */

data "aws_organizations_organization" "org_accounts" {
    depends_on              = [aws_organizations_account.child_accs]
}

/* 
 * Creates an S3 bucket where all account CloudTrail trails will deliver logs to. 
 */

module "org_trail" {
    source                  = "./modules/OrganizationTrail"
    /* TODO: For now the account designated for storing all CloudTrail logs must be named "logs" */
    log_acc_id              = data.aws_organizations_organization.org_accounts.non_master_accounts[index(data.aws_organizations_organization.org_accounts.non_master_accounts.*.name, "logs")].id
    org_trail_bucket_name   = var.org_trail_bucket_name
    //child_accs_ids          = aws_organizations_account.child_accs.*.id
    child_accs_ids          = data.aws_organizations_organization.org_accounts.accounts.*.id
}

/* 
 * Turn on CloudTrail on root account and deliver to s3 bucket in logs account 
 */

module "root_trail" {
    source                      = "../global-modules/EnableAccountCloudTrail"

    trail_name                  = "root-acc-trail"
    dest_bucket_name            = module.org_trail.org_trail_bucket_id
    org_trail_kms_key_id        = var.org_cloudtrail_key_arn
}

/*module "import_initial_iam_user" {
    source                      = "./modules/InitialIAMUser"

    initial_user_name           = var.initial_iam_user_name
}*/