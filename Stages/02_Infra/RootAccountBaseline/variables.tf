variable "child_accounts" {
    type = list(object({
        name    = string
        email   = string
    }))
}

variable "org_trail_bucket_name" {
    type        = string
}

variable "org_service_access_principals" {
    type        = list(string)
    default     = [ "cloudtrail.amazonaws.com", "config.amazonaws.com" ]
}

variable "org_cloudtrail_key_arn" {
    type        = string
}

#variable "initial_iam_user_name" {
#    type        = string
#}