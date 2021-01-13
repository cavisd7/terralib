variable "org_trail_bucket_id" {
    type = string
}

variable "shared_acc_roles" {
    type = list(string)
}

variable "shared_acc_id" {
    type = string
}

variable "sec_acc_id" {
    type = string 
}

variable "enable_cross_account_cloudwatch_monitoring" {
    type    = bool
    default = false
}

/* Typically logs account */
variable "monitoring_acc_id" {
    type = string
}