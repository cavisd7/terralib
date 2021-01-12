variable "child_accounts" {
    type = list(object({
        name    = string
        email   = string
    }))
}

variable "org_trail_bucket_name" {
    type = string
}

variable "admin_users" {
    type = list(object({
        name            = string
        pgp_key         = string 
    }))
    default = []
}