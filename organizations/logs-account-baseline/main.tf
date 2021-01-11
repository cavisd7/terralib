/* Turn on CloudTrail in logs account */
resource "aws_cloudtrail" "log-acc-trail" {
    name                    = "log-acc-trail"
    s3_bucket_name          = var.org_trail_bucket_name
}

/* Allow users kept in the security & identity account to assume roles in the logs account */
data "aws_iam_policy_document" "cross_account_role_policy" {
    version                 = "2012-10-17"
    statement {
        sid                 = "CrossAccountAccess"
        effect              = "Allow"
        principals {
            type            = "AWS"
            identifiers     = ["arn:aws:iam::${var.sec_acc_id}:root"]
        }
        actions             = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "cross_account_role" {
    count                   = length(var.log_acc_roles)
    name                    = var.log_acc_roles[count.index]
    assume_role_policy      = data.aws_iam_policy_document.cross_account_role_policy.json
}