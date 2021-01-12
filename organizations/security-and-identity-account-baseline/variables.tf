variable "sec_acc_id" {
    type = string
}

variable "org_trail_bucket_id" {
    type = string
}

variable "groups" {
    type = list(object({
        group_name      = string
        iam_role_arns   = list(string)
    })) 
}

variable "users" {
    type = list(object({
        name            = string
        groups          = list(string)
        pgp_key         = string 
    }))
}

variable "enable_cross_account_cloudwatch_monitoring" {
    type    = bool
    default = false
}

/* Typically logs account */
variable "monitoring_acc_id" {
    type = string
}