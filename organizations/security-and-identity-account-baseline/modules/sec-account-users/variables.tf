variable "name" {
    type = string
}

variable "groups" {
    type = list(string)
}

variable "pgp_key" {
    type    = string
    default = null
}