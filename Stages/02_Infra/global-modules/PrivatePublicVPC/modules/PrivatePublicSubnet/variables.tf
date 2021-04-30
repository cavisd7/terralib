variable "vpc_cidr_block" {
    type = string
} 

# Limit for available AZs
variable "subnet_count" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "eks_cluster_name" {
    type = string 
}