output "user_arns" {
  value = { for username, user in aws_iam_user.users : username => user.arn }
}