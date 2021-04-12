/*
 * Local Variables
 */

locals {
    plan_codebuild_log_group_name = "${var.codebuild_log_group_prefix}-plan"
    apply_codebuild_log_group_name = "${var.codebuild_log_group_prefix}-apply"
}

/*
 * CodePipeline Artifact Bucket
 */

resource "aws_s3_bucket" "pipeline_artifact_bucket" {
    bucket              = var.pipeline_bucket_name

    force_destroy       = true

    tags = {
        pipeline = "true"
    }
}

/*
 * CodeBuild Logs Bucket
 */

resource "aws_s3_bucket" "codebuild_logs_bucket" {
    bucket              = var.codebuild_bucket_name

    force_destroy       = true
}

/*
 * .tfvars Bucket
 */

resource "aws_s3_bucket" "tfvars_bucket" {
    bucket              = "main-org-infra-tfvars"

    force_destroy       = true

    versioning {
        enabled = true
    }
}

/*
 * Terraform plan CodeBuild Project 
 */

resource "aws_cloudwatch_log_group" "plan_codebuild_log_group" {
    name                = local.plan_codebuild_log_group_name
    retention_in_days   = "7"
}

/*
 * Terraform apply CodeBuild Project 
 */

resource "aws_cloudwatch_log_group" "apply_codebuild_log_group" {
    name                = local.apply_codebuild_log_group_name
    retention_in_days   = "7"
}

/*
 * CodeStart Connection
 */

resource "aws_codestarconnections_connection" "github_connection" {
    name                = "terralib-github"
    provider_type       = "GitHub"
}

/*
 * Pipeline SNS Topic
 */

/*resource "aws_sns_topic" "pipeline_approval_topic" {
    name                = "org-infra-pipeline"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
    count               = length(var.pipeline_subscribers)

    topic_arn           = aws_sns_topic.pipeline_approval_topic.arn
    protocol            = "email"
    endpoint            = var.pipeline_subscribers[count.index]
}*/

/*
 * CodeBuild project used as the terraform plan stage in the pipeline
 */

resource "aws_codebuild_project" "plan_org_infra_project" {
    name                = "${var.pipeline_name}-plan"
    description         = "Plan terraform modules for all accounts in organization"
    build_timeout       = "10"
    service_role        = var.codebuild_service_role_arn

    artifacts {
        type            = "CODEPIPELINE"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = var.container_image
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "SERVICE_ROLE"

        registry_credential {
            credential              = var.docker_credentials
            credential_provider     = "SECRETS_MANAGER"
        }

        environment_variable {
            name    = "TFVARS_BUCKET_NAME"
            value   = aws_s3_bucket.tfvars_bucket.id
        }

        environment_variable {
            name    = "INFRA_STAGE_PREFIX"
            value   = "stages/02_infra"
        }
    }

    source {
        type            = "CODEPIPELINE"
        buildspec       = file("buildspec/plan.yml")
    } 

    logs_config {
        cloudwatch_logs {
            group_name  = local.plan_codebuild_log_group_name
        }

        s3_logs {
            status      = "ENABLED"
            location    = "${aws_s3_bucket.codebuild_logs_bucket.id}/${var.pipeline_name}-plan"
        }
    }
}

/*
 * CodeBuild project used as the terraform apply stage in the pipeline
 */

resource "aws_codebuild_project" "apply_org_infra_project" {
    name                = "${var.pipeline_name}-apply"
    description         = "Apply terraform modules for all accounts in organization"
    build_timeout       = "10"
    service_role        = var.codebuild_service_role_arn

    artifacts {
        type            = "CODEPIPELINE"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = var.container_image
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "SERVICE_ROLE"

        registry_credential {
            credential              = var.docker_credentials
            credential_provider     = "SECRETS_MANAGER"
        }

        environment_variable {
            name    = "TFVARS_BUCKET_NAME"
            value   = aws_s3_bucket.tfvars_bucket.id
        }

        environment_variable {
            name    = "INFRA_STAGE_PREFIX"
            value   = "stages/02_infra"
        }
    }

    source {
        type                = "CODEPIPELINE"
        buildspec           = file("buildspec/apply.yml")
    }

    logs_config {
        cloudwatch_logs {
            group_name  = local.apply_codebuild_log_group_name
        }

        s3_logs {
            status      = "ENABLED"
            location    = "${aws_s3_bucket.codebuild_logs_bucket.id}/${var.pipeline_name}-apply"
        }
    }
}

/*
 * Main pipeline for all organization infrastructure
 * TODO: Artifact store encryption   
 */

resource "aws_codepipeline" "org_infra_codepipeline" {
    name                = var.pipeline_name
    role_arn            = var.codepipeline_service_role_arn

    artifact_store {
        type            = "S3"
        location        = aws_s3_bucket.pipeline_artifact_bucket.bucket
    }

    stage {
        name            = "Source"

        action {
            name                = "Source"
            category            = "Source"
            owner               = "AWS"
            provider            = "CodeStarSourceConnection"
            version             = "1"
            output_artifacts    = ["tfcode"]
            configuration = {
                FullRepositoryId        = var.full_repo_id
                BranchName              = var.branch_name
                ConnectionArn           = aws_codestarconnections_connection.github_connection.arn
                OutputArtifactFormat    = "CODE_ZIP"
            }
        }

        action{
            name                = "Source2"
            category            = "Source"
            owner               = "AWS"
            provider            = "S3"
            version             = "1"
            output_artifacts    = ["tfvars"]
            configuration = {
                S3Bucket        = "main-org-infra-tfvars"
                S3ObjectKey     = "stages/02_infra/infra_tfvars.zip"
            }
        }
    }

    stage {
        name = "Plan"

        action {
            name                = "Build"
            category            = "Build"
            owner               = "AWS"
            provider            = "CodeBuild"
            input_artifacts     = ["tfcode", "tfvars"]
            version             = "1"

            configuration = {
                ProjectName     = aws_codebuild_project.plan_org_infra_project.id
                PrimarySource   = "tfcode"
            }
        }
    }

    stage {
        name = "Approval"

        action {
            category    = "Approval"
            owner       = "AWS"
            name        = "Approval"
            provider    = "Manual"
            version     = "1"
        }

        /*configuration = {
            NotificationArn = aws_sns_topic.pipeline_approval_topic.arn
        }*/
    } 

    stage {
        name = "Apply"

        action {
            name            = "Apply"
            category        = "Build"
            owner           = "AWS"
            provider        = "CodeBuild"
            input_artifacts = ["tfcode", "tfvars"]
            version         = "1"

            configuration = {
                ProjectName     = aws_codebuild_project.apply_org_infra_project.id
                PrimarySource   = "tfcode"
            }
        }
    }
}