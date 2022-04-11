resource "aws_iam_user" "aws-usp" {
  count = "${length(var.username)}"
  name = "${element(var.username,count.index )}"
}

resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

resource "aws_iam_group" "admins" {
  name = "admins"
  path = "/users/"
}

resource "aws_iam_group" "read_only" {
  name = "read-only"
  path = "/users/"
}

resource "aws_iam_group_policy" "developers" {
  name  = "DevelopersPolicty"
  group = aws_iam_group.developers.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy" "admins" {
  name  = "AdminsPolicy"
  group = aws_iam_group.admins.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy" "read_only" {
  name  = "ReadOnlyPolicy"
  group = aws_iam_group.read_only.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_membership" "dev" {
  name = "dev"

  users = var.username_dev

  group = aws_iam_group.developers.name
}

resource "aws_iam_group_membership" "admins" {
  name = "admins"

  users = var.username_admins

  group = aws_iam_group.admins.name
}

resource "aws_iam_group_membership" "read_only" {
  name = "read-only"

  users = var.username_read_only

  group = aws_iam_group.read_only.name
}