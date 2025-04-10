resource "aws_iam_group" "general" {
  name = "general"
  path = "/users/"
}

resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

resource "aws_iam_group" "read_only" {
  name = "read-only"
  path = "/users/"
}

resource "aws_iam_group" "admin" {
  name = "admin"
  path = "/users/"
}

locals {
  users_and_groups = jsondecode(file("${path.module}/users_and_groups.json"))
}

resource "aws_iam_user" "users" {
  for_each = local.users_and_groups.users

  name = each.key
}

resource "aws_iam_group_membership" "group_memberships" {
  for_each = local.users_and_groups.users

  name  = each.key
  users = [aws_iam_user.users[each.key].name]

  group = each.value != null ? each.value : null
}



resource "aws_iam_role" "grafana_read_billing_role" {
  name = "grafana_read_billing_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "grafana.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "cloudwatch_logs_read_attachment" {
  name       = "cloudwatch_logs_read_attachment"
  policy_arn = aws_iam_policy.cloudwatch_logs_read_policy.arn
  roles      = [aws_iam_role.grafana_read_billing_role.name]
}

resource "aws_iam_policy_attachment" "ec2_cloudwatch_read_attachment" {
  name       = "ec2_cloudwatch_read_attachment"
  policy_arn = aws_iam_policy.ec2_cloudwatch_read_policy.arn
  roles      = [aws_iam_role.grafana_read_billing_role.name]
}

resource "aws_iam_policy_attachment" "tag_read_attachment" {
  name       = "tag_read_attachment"
  policy_arn = aws_iam_policy.tag_read_policy.arn
  roles      = [aws_iam_role.grafana_read_billing_role.name]
}

resource "aws_iam_policy" "eks_admin_policy" {
  name        = "eks-admin-policy"
  description = "EKS admin policy for managing EKS clusters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "eks_admin_role" {
  name = "eks-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for user, role in local.users_and_groups.users : {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/${user}"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_policy_attachment" {
  for_each = { for idx, policy_arn in local.policies : idx => policy_arn }

  role       = aws_iam_role.eks_admin_role.name
  policy_arn = each.value
}
