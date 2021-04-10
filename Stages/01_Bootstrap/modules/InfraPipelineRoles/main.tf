/*
 *  CodePipeline Service Role Permissions
 */

data "aws_iam_policy_document" "codepipeline_service_role_policy" {
    statement {
        sid = "S3Read"

        actions = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning"
        ]

        resources = ["arn:aws:s3:::${var.pipeline_bucket_name}"]

        effect = "Allow"
    }

    statement {
        sid = "S3Write"

        actions = [
            "s3:PutObject"
        ]

        resources = ["arn:aws:s3:::${var.pipeline_bucket_name}"]

        effect = "Allow"
    }

    statement {
        sid = "AllowGeneralServices"

        actions = [
            "ec2:*",
            "elasticloadbalancing:*",
            "autoscaling:*",
            "cloudwatch:*",
            "s3:*",
            "sns:*",
            "cloudformation:*",
            "rds:*",
            "sqs:*",
            "ecs:*",
            "iam:PassRole"
        ]

        resources = ["*"]

        effect = "Allow"
    }

    statement {
        sid = "CodeBuildPermissions"

        actions = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
        ]

        resources = ["${var.codebuild_plan_project_arn}", "${var.codebuild_apply_project_arn}"]

        effect = "Allow"
    }

    statement {
        sid = "AllowCodeStarConnection"

        actions = ["codestar-connections:UseConnection"]

        resources = ["${var.codestar_connection_arn}"]

        effect = "Allow"
    }
}

/*
 *  CodePipeline Service Role
 */

resource "aws_iam_role" "codepipeline_service_role" {
    name = "OrgInfraCodePipelineServiceRole"
    description = "CodePipeline service role for deploying infrastructure provisioned by terraform into all accounts in organization"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AssumableByCodePipeline",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF

    inline_policy {
        name = "CodePipelinePermissions"
        policy = data.aws_iam_policy_document.codepipeline_service_role_policy.json
    }

    tags = {
        pipeline = "true"
    }
}

/*
 *  CodeBuild Service Role Permissions
 *  TODO: Tighten permissions
 */

data "aws_iam_policy_document" "codebuild_service_role_policy" {
    statement {
        sid = ""
        actions = [
            "logs:*", 
            "s3:*", 
            "codebuild:*", 
            "secretsmanager:*",
            "iam:*"
        ]
        resources = ["*"]
        effect = "Allow"
    }
}

/*
 *  CodeBuild Service Role
 */

resource "aws_iam_role" "codebuild_service_role" {
    name = "OrgInfraCodeBuildServiceRole"
    description = "CodeBuild service role for deploying infrastructure provisioned by terraform into all accounts in organization"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AssumableByCodeBuild",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF

    inline_policy {
        name = "CodeBuildPermissions"
        policy = data.aws_iam_policy_document.codebuild_service_role_policy.json
    }
}