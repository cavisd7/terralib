resource "aws_iam_group" "admin-group" {
    name            = "admins"
}

data "aws_iam_policy" "admin-access" {
    arn             = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "admin-group-attach" {
    group           = aws_iam_group.admin-group.name
    policy_arn      = data.aws_iam_policy.admin-access.arn
}