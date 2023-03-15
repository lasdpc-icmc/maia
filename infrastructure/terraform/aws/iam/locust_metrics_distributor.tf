resource "aws_iam_user" "locust-metrics-distributor" {
  name = "locust-metrics-distributor"
}

resource "aws_iam_access_key" "locust-metrics-distributor" {
  user = aws_iam_user.locust-metrics-distributor.name
}

data "aws_iam_policy_document" "locust-metrics-distributor" {
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

resource "aws_iam_user_policy" "locust-metrics-distributor" {
  name   = "${terraform.workspace}-locust-metrics-distributor"
  user   = aws_iam_user.locust-metrics-distributor.name
  policy = data.aws_iam_policy_document.locust-metrics-distributor.json
}

output "secret" {
  value = aws_iam_access_key.locust-metrics-distributor.secret
  sensitive = true
}

