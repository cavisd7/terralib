/* Create users in sec & identity account */
resource "aws_iam_user" "users" {
    name            = var.name
}

/* Put users in groups */
resource "aws_iam_user_group_membership" "memberships" {
    user            = var.name
    groups          = var.groups

    depends_on      = [aws_iam_user.users]
}

resource "aws_iam_user_login_profile" "profiles" {
    count           = var.pgp_key != null ? 1 : 0

    user            = var.name
    pgp_key         = var.pgp_key

    depends_on      = [aws_iam_user.users]
}