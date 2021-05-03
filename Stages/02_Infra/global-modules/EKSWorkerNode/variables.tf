variable "cluster_name" {
    type = string 
}

variable "node_group_name" {
    type = string 
}

variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
}