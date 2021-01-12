output "admin_encrypted_password" {
    value = aws_iam_user_login_profile.profile.encrypted_password
}