/*
 * Root Account Baseline
 */

module "root_account_baseline" {
    source                                          = "./RootAccountBaseline"

    child_accounts                                  = var.child_accounts
    org_trail_bucket_name                           = var.org_trail_bucket_name
}

/*
 * Log Account Baseline
 */

module "log_account_baseline" {
    source                                          = "./LogAccountBaseline"

    log_acc_roles                                   = var.log_acc_roles
    org_trail_bucket_id                             = module.root_account_baseline.org_trail_bucket_id
    log_acc_id                                      = module.root_account_baseline.log_acc_id
    sec_acc_id                                      = module.root_account_baseline.sec_acc_id
}

/*
 * Identity Account Baseline
 */

module "identity_account_baseline" {
    source                                          = "./IdentityAccountBaseline"

    sec_acc_id                                      = module.root_account_baseline.sec_acc_id
    org_trail_bucket_id                             = module.root_account_baseline.org_trail_bucket_id
    groups                                          = var.iam_groups
    users                                           = var.iam_users
}

/*
 * Shared Services Account Baseline
 */

module "shared_account_baseline" {
    source                                          = "./SharedServicesAccountBaseline"

    sec_acc_id                                      = module.root_account_baseline.sec_acc_id
    org_trail_bucket_id                             = module.root_account_baseline.org_trail_bucket_id
    shared_acc_id                                   = module.root_account_baseline.shared_acc_id
    shared_acc_roles                                = var.shared_acc_roles
}