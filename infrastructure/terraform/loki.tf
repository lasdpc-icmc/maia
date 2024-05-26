resource "aws_s3_bucket" "loki_logs" {
  bucket = "lasdpc-loki-logs"

  tags = {
    Name        = "Loki Logs"
    Environment = "core"
  }
}

resource "aws_iam_role" "loki_role" {
  name = "loki_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : module.eks.oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(module.eks.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:monitoring:loki-service"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "loki_policy" {
  name = "loki_policy"
  role = aws_iam_role.loki_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:DeleteObject"
        ],
        "Resource": [
          "${aws_s3_bucket.loki_logs.arn}",
          "${aws_s3_bucket.loki_logs.arn}/*"
        ]
      }
    ]
  })
}

resource "helm_release" "loki" {
  name              = "loki"
  chart             = "loki-stack"
  repository        = "https://grafana.github.io/helm-charts"
  version           = "2.10.2"
  timeout           = "600"
  dependency_update = true
  values            = [
    templatefile("helm-manifests/loki.tpl", {
      environment = var.environment,
      role_arn = aws_iam_role.loki_role.arn
    })
  ]
  namespace         = "monitoring"
  depends_on        = [helm_release.kube_prometheus]
}

output "loki_role_arn" {
  value = aws_iam_role.loki_role.arn
}
