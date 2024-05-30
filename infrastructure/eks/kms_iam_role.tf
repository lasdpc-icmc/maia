resource "aws_iam_access_key" "vault_kms" {
  user = aws_iam_user.vault_kms.name
}

resource "aws_iam_user" "vault_kms" {
  name = "vault-kms"
  path = "/system/"
}

resource "aws_iam_user_policy" "vault_kms_access" {
  name = "vault-kms-access"
  user = aws_iam_user.vault_kms.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

