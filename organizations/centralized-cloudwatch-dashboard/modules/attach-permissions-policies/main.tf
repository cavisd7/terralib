data "aws_iam_policy" "permission_policy" {
    arn = "arn:aws:iam::aws:policy/${var.policy_name}"
}

resource "aws_iam_role_policy_attachment" "attach-policy" {
    role                = var.role_name
    policy_arn          = data.aws_iam_policy.permission_policy.arn
}
//arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess
//arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess
//arn:aws:iam::aws:policy/CloudWatchAutomaticDashboardsAccess