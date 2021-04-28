/* Create a pipeline that will be used to deploy terraform modules for the entire AWS organization */
/* This stage will be run locally on your machine */

data "aws_region" "current_region" {}

locals {
    pipeline_bucket_name        = "codepipeline-${data.aws_region.current_region.name}-${var.pipeline_name}"
    codebuild_bucket_name       = "codebuild-${data.aws_region.current_region.name}-${var.pipeline_name}"
    codebuild_log_group_prefix  = "codebuild-${data.aws_region.current_region.name}-${var.pipeline_name}"
}

module "org_pipeline_roles" {
    source                          = "./modules/InfraPipelineRoles"

    pipeline_bucket_name            = local.pipeline_bucket_name
    codebuild_plan_project_arn      = module.org_infra_pipeline.codebuild_plan_project_arn
    codebuild_apply_project_arn     = module.org_infra_pipeline.codebuild_apply_project_arn
    codestar_connection_arn         = module.org_infra_pipeline.codestar_connection_arn
}

module "org_infra_pipeline" {
    source                          = "./modules/InfraPipeline"
    
    pipeline_name                   = var.pipeline_name
    pipeline_bucket_name            = local.pipeline_bucket_name
    codebuild_bucket_name           = local.codebuild_bucket_name
    codebuild_log_group_prefix      = local.codebuild_log_group_prefix
    codepipeline_service_role_arn   = module.org_pipeline_roles.codepipeline_service_role_arn
    codebuild_service_role_arn      = module.org_pipeline_roles.codebuild_service_role_arn
    docker_credentials              = var.docker_credentials
    container_image                 = var.container_image
    full_repo_id                    = var.full_repo_id
    branch_name                     = var.branch_name
    #initial_iam_user_name           = var.initial_iam_user_name
}