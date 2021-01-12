/**
setup cloudwatch sharing in other accounts by making CloudWatch-CrossAccountSharingRole role 
create new dashboard in logs account 

*/

data "aws_iam_policy_document" "cloudwatch_cross_account_role_policy" {
    version                 = "2012-10-17"
    statement {
        sid                 = "CloudWatchMonitoringAccountAccess"
        effect              = "Allow"
        principals {
            type            = "AWS"
            identifiers     = ["arn:aws:iam::${var.monitoring_acc_id}:root"]
        }
        actions             = ["sts:AssumeRole"]
    }
}

/* Create a role for cross-account CloudWatch monitoring */
resource "aws_iam_role" "cloudwatch_role" {
    name                = "CloudWatch-CrossAccountSharingRole"
    assume_role_policy  = data.aws_iam_policy_document.cloudwatch_cross_account_role_policy.json
}

module "cloudwatch_attach_permissions_policies" {
    count               = length(var.permissions_policies)
    source              = "./modules/attach-permissions-policies"

    role_name           = aws_iam_role.cloudwatch_role.name
    policy_name         = var.permissions_policies[count.index]
}
