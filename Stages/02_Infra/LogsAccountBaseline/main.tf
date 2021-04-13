data "aws_iam_policy_document" "org_cloudtrail_key_policy" {
    version = "2012-10-17"

    statement {
        sid    = "Allow CloudTrail to encrypt logs"
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = ["cloudtrail.amazonaws.com"]
        }

        actions   = ["kms:GenerateDataKey"]
        resources = ["*"]

        condition {
            test    = "StringLike"
            variable = "kms:EncryptionContext:aws:cloudtrail:arn"
            values = [
                for acc_id in var.acc_ids:
                    "arn:aws:cloudtrail:*:${acc_id}:trail/*"
            ]
        }
    }

    statement {
        sid    = "Enable CloudTrail log decrypt permissions"
        effect = "Allow"

        principals {
            type        = "AWS"
            identifiers = [
                for acc_id in var.acc_ids:
                    "arn:aws:iam::${acc_id}:root"
            ]
        }

        actions   = ["kms:Decrypt"]
        resources = ["*"]

        condition {
            test    = "Null"
            variable = "kms:EncryptionContext:aws:cloudtrail:arn"
            values = [ "false" ]
        }
    }

    statement {
        sid    = "Allow CloudTrail access"
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = [ "cloudtrail.amazonaws.com" ]
        }

        actions   = ["kms:DescribeKey"]
        resources = ["*"]
    }
}

resource "aws_kms_key" "org_cloudtrail_key" {
    description                 = "KMS key 1"
    deletion_window_in_days     = 7

    key_usage                   = "ENCRYPT_DECRYPT"
    customer_master_key_spec    = "SYMMETRIC_DEFAULT"
    policy                      = data.aws_iam_policy_document.org_cloudtrail_key_policy.json
}

/* 
 * Turn on CloudTrail in logs account 
 */

module "log_acc_trail" {
    source                  = "../global-modules/EnableAccountCloudTrail"

    trail_name              = "log-acc-trail"
    dest_bucket_name        = var.org_trail_bucket_id

    org_trail_kms_key_id    = aws_kms_key.org_cloudtrail_key.arn
}

/* 
 * Allow users kept in the security & identity account to assume roles in the logs account 
 * TODO: make into separate module
 */

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