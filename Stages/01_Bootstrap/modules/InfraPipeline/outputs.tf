output "codestar_connection_arn" {
    value = aws_codestarconnections_connection.github_connection.arn
}

output "codebuild_apply_project_arn" {
    value = aws_codebuild_project.apply_org_infra_project.arn
}

output "codebuild_plan_project_arn" {
    value = aws_codebuild_project.plan_org_infra_project.arn
}