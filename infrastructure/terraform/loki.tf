resource "helm_release" "loki" {
  name              = "loki"
  chart             = "loki-stack"
  repository        = "https://grafana.github.io/helm-charts"
  version           = "2.9.11"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/loki.tpl", { environment = var.environment })]
  namespace         = "monitoring"
  depends_on        = [helm_release.kube_prometheus]
}

data "aws_eks_cluster" "eks" {
  name = "lasdpc-icmc"
}

# Extract the OIDC issuer URL from the cluster
locals {
  oidc_issuer_url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# Create S3 bucket
resource "aws_s3_bucket" "loki_logs" {
  bucket = "lasdpc-loki-logs"
  acl    = "private"
}

# Create IAM role
resource "aws_iam_role" "loki_role" {
  name = "loki-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_issuer_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_url}:sub" = "system:serviceaccount:monitoring:loki-service-account"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "loki_policy" {
  name        = "loki-s3-write-policy"
  description = "Policy to allow Loki to write to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.loki_logs.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.loki_logs.bucket}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki_policy_attachment" {
  role       = aws_iam_role.loki_role.name
  policy_arn = aws_iam_policy.loki_policy.arn
}

output "loki_role_arn" {
  value = aws_iam_role.loki_role.arn
}