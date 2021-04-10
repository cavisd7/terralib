variable "pipeline_bucket_name" {
    type        = string
}

variable "codebuild_plan_project_arn" {
    type        = string 
    description = "Enter ARN value of CodeBuild project for the terraform plan stage"
}

variable "codebuild_apply_project_arn" {
    type        = string 
    description = "Enter ARN value of CodeBuild project for the terraform apply stage"
}

variable "codestar_connection_arn" {
    type        = string 
    description = "Enter the ARN of the CodeStar connection"
}