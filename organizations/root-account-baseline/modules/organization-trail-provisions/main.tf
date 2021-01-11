/*data "aws_iam_policy_document" "ct_bucket_key_policy" {

}

resource "aws_kms_key" "ct_key" {
    description             = "A KMS key to encrypt CloudTrail events."
    //deletion_window_in_days = var.key_deletion_window_in_days
    //enable_key_rotation     = "true"
    policy                  = data.aws_iam_policy_document.cloudtrail_bucket_key_policy.json
}*/

/* Create s3 bucket in logs account where organization CloudTrail logs will be stored 
 * TODO: Enable encryption
 */
resource "aws_s3_bucket" "ct_bucket" {
    bucket                  = var.org_trail_bucket_name
    force_destroy           = true

    /*server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                kms_master_key_id = aws_kms_key.mykey.arn
                sse_algorithm     = "aws:kms"
            }
        }
    }*/
}

/* Create a policy for the organization trail bucket. Give CloudTrail permissions to deliver logs to bucket. */
data "aws_iam_policy_document" "ct_bucket_policy" {
    version                 = "2012-10-17"
    statement {
        sid                 = "AWSCloudTrailAclCheck"
        effect              = "Allow"
        principals {
            type            = "Service"
            identifiers     = ["cloudtrail.amazonaws.com"]
        }
        actions             = ["s3:GetBucketAcl"]
        resources           = [aws_s3_bucket.ct_bucket.arn]
    }

    statement {
        sid                 = "AWSCloudTrailWrite"
        effect              = "Allow"
        principals {
            type            = "Service"
            identifiers     = ["cloudtrail.amazonaws.com"]
        }
        actions             = ["s3:PutObject"]
        resources           = [for acc_id in var.child_accs_ids: "${aws_s3_bucket.ct_bucket.arn}/AWSLogs/${acc_id}/*"]
        condition {
            test = "StringEquals"
            variable = "s3:x-amz-acl"
            values = ["bucket-owner-full-control"]
        }
    }
}

/* Attach policy to bucket */
resource "aws_s3_bucket_policy" "attach_ct_bucket_policy" {
    bucket                  = aws_s3_bucket.ct_bucket.id
    policy                  = data.aws_iam_policy_document.ct_bucket_policy.json
}