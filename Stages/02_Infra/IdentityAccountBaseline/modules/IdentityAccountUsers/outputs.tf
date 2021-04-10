output "user_encrypted_password" {
    value = aws_iam_user_login_profile.profiles.*.encrypted_password
}