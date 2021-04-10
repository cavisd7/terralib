variable "codebuild_service_role_arn" {
    type        = string 
    description = "Service role for Codebuild"
}

variable "codepipeline_service_role_arn" {
    type        = string 
    description = "Service role for CodePipeline"
}

variable "docker_credentials" {
    type        = string 
    description = "DockerHub credentials needed to reliably access registry for CodeBuild"
}

variable "container_image" {
    type        = string
    description = "The terraform docker image used for CodeBuild projects"
}

variable "full_repo_id" {
    type        = string 
}

variable "branch_name" {
    type        = string 
}

variable "pipeline_bucket_name" {
    type        = string
}

variable "codebuild_bucket_name" {
    type        = string
} 

variable "codebuild_log_group_prefix" {
    type        = string
}

variable "pipeline_name" {
    type        = string
}