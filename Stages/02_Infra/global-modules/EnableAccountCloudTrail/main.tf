resource "aws_cloudtrail" "root_trail" {
    name                        = var.trail_name
    s3_bucket_name              = var.dest_bucket_name
    kms_key_id                  = var.org_trail_kms_key_id
    is_multi_region_trail       = true
    enable_log_file_validation  = true
}