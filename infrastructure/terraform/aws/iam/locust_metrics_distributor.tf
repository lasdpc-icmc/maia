data "aws_iam_policy_document" "locust-distributor-policydocument" {
  statement {
    sid       = "AllowReadLocustBucket"
    effect    = "Allow"
    actions   = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_locust_name}",
      "arn:aws:s3:::${var.bucket_locust_name}/*",
    ]
  }
}

data "aws_iam_policy_document" "locust-distributor-rolepolicydocument" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${var.oidc_provider}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test = "ForAnyValue:StringEquals"
      variable = "${var.oidc_provider}:aud"
      values = ["sts.amazonaws.com"]
    }

    condition {
      test = "ForAnyValue:StringEquals"
      variable = "${var.oidc_provider}:sub"
      values = ["system:serviceaccount:monitoring:locust-distributor-serviceaccount"]
    }
  }
}

resource "aws_iam_policy" "locust-distributor-policy" {
  name   = "locust-distributor-policy"
  policy = data.aws_iam_policy_document.locust-distributor-policydocument.json
}

resource "aws_iam_role" "locust-distributor-role" {
  name = "locust-distributor-role"
  assume_role_policy = data.aws_iam_policy_document.locust-distributor-rolepolicydocument.json
}

resource "aws_iam_role_policy_attachment" "locust-distributor-roleattach" {
  role       = aws_iam_role.locust-distributor-role.name
  policy_arn = aws_iam_policy.locust-distributor-policy.arn
}

