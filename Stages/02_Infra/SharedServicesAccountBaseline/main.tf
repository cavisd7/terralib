/* Turn on CloudTrail in shared account */
resource "aws_cloudtrail" "shared-acc-trail" {
    name                    = "shared-acc-trail"
    s3_bucket_name          = var.org_trail_bucket_id
}

/* Allow users kept in the security & identity account to assume roles in the shared account */
/* TODO: make into separate module*/
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
    count                   = length(var.shared_acc_roles)
    name                    = var.shared_acc_roles[count.index]
    assume_role_policy      = data.aws_iam_policy_document.cross_account_role_policy.json
}
