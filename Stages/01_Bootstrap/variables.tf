variable "aws_profile_name" {
    type        = string
    default     = "default"
}

variable "initial_iam_user_name" {
    type        = string
}

variable "container_image" {
    type        = string
    default     = "hashicorp/terraform:latest"
}

variable "full_repo_id" {
    type        = string
}

variable "branch_name" {
    type        = string
}

variable "pipeline_name" {
    type        = string 
    default     = "org-infra"
}

variable "docker_credentials" {
    type        = string 
}