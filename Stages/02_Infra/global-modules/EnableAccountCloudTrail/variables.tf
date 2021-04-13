variable "trail_name" {
    type = string 
}

variable "dest_bucket_name" {
    type = string 
    description = "Id of bucket in logs account where CloudTrail will deliver logs to"
}

variable "org_trail_kms_key_id" {
    type = string
}