variable "child_accounts" {
    type = list(object({
        name    = string
        email   = string
    }))
}

variable "org_trail_bucket_name" {
    type = string
}

variable "log_acc_roles" {
    type = list(string)
}

variable "iam_groups" {
    type = list(object({
        group_name      = string
        iam_role_arns   = list(string)
    })) 
}

variable "iam_users" {
    type = list(object({
        name            = string
        groups          = list(string)
        pgp_key         = string 
    }))
}

variable "shared_acc_roles" {
    type = list(string)
}