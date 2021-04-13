/* 
 * Initial IAM user that was created via the AWS console will be imported into terraform's state here 
 */

resource "aws_iam_user" "initial_user" {
    name            = var.initial_user_name
}

/* 
 * Initial IAM group that was created via the AWS console will be imported into terraform's state here 
 */

resource "aws_iam_group" "initial_group" {
    name            = var.initial_group_name
}

resource "aws_iam_group_policy_attachment" "admin-group-attach" {
    group           = aws_iam_group.initial_group.name
    policy_arn      = "arn:aws:iam::aws:policy/AdministratorAccess"
}

/* Put user in group */
resource "aws_iam_user_group_membership" "memberships" {
    user            = aws_iam_user.initial_user.name
    groups          = aws_iam_group.initial_group.name
}

/*resource "aws_iam_user_login_profile" "profile" {
    count           = var.pgp_key != null ? 1 : 0

    user            = aws_iam_user.initial_user.name
    pgp_key         = var.pgp_key
}*/