resource "aws_iam_role" "vault-unseal" {
  name = "vault-unseal"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::326123346670:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D24C5025164533C85B138C68071B5515"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-1.amazonaws.com/id/D24C5025164533C85B138C68071B5515:sub": "system:serviceaccount:vault:vault"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "core"
  }
}

resource "aws_iam_role_policy" "vault-unseal" {
  name = "vault-unseal"
  role = aws_iam_role.vault-unseal.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:GetRole",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:role/vault-unseal"
      },
      {
        Action = [
          "kms:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "vault" {
  name = "vault"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::326123346670:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D24C5025164533C85B138C68071B5515"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-1.amazonaws.com/id/D24C5025164533C85B138C68071B5515:sub": "system:serviceaccount:vault:boot-vault"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "core"
  }
}

resource "aws_iam_role_policy" "vault" {
  name = "vault"
  role = aws_iam_role.vault.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.caller_identity.account_id}:log-group:vault-audit-logs"
      },
      {
        Action = [
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.caller_identity.account_id}:log-group:vault-audit-logs:log-stream:*"
      },
      {
        Action = [
          "ec2:DescribeInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:UpdateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.vault-secret.arn
      },
      {
        Action = [
          "iam:GetRole"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:role/vault"
      }
    ]
  })
}

resource "aws_kms_key" "vault-kms" {
  description             = "Vault Seal/Unseal key"
  deletion_window_in_days = 7

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Action": [
        "kms:*"
      ],
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:root"
      },
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Allow administration of the key",
      "Action": [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:root",
      "Principal": {
        "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:role/vault",
            "arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:role/vault-unseal"
        ]
       }
    },
    {
      "Sid": "Allow use of the key",
      "Action": [
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey",
        "kms:GenerateDataKeyWithoutPlaintext"
      ],
      "Principal": {
        "AWS": [
            "${aws_iam_role.vault.arn}",
            "${aws_iam_role.vault-unseal.arn}"
        ]
      },
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOT
}

resource "random_string" "vault-secret-suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret" "vault-secret" {
  name        = "vault-EKS-secret-${random_string.vault-secret-suffix.result}"
  kms_key_id  = aws_kms_key.vault-kms.key_id
  description = "Vault Root/Recovery key"
  depends_on  = [resource.aws_kms_key.vault-kms]
}

resource "aws_s3_bucket" "vault-scripts" {
  bucket = "lasdpc-${var.environment}-k8s-vault-scripts"
  acl    = "private"

  tags = {
    Name        = "Vault Scripts"
    Environment = "core"
  }
}

resource "aws_s3_bucket_object" "vault-script-bootstrap" {
  bucket = aws_s3_bucket.vault-scripts.id
  key    = "scripts/bootstrap.sh"
  source = "scripts/bootstrap.sh"
  etag   = filemd5("scripts/bootstrap.sh")
}

resource "aws_s3_bucket_object" "vault-script-certificates" {
  bucket = aws_s3_bucket.vault-scripts.id
  key    = "scripts/certificates.sh"
  source = "scripts/certificates.sh"
  etag   = filemd5("scripts/certificates.sh")
}

# Create Vault Namespace
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

# Create and sign Vault certificates
resource "kubernetes_job" "vault-initialization" {
  metadata {
    name      = "boot-vault"
    namespace = "vault"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "boot-vault"
          image   = "amazonlinux"
          command = ["/bin/bash", "-c"]
          args    = ["sleep 15; yum install -y awscli 2>&1 > /dev/null; export AWS_REGION=${var.region}; aws sts get-caller-identity; aws s3 cp $(S3_SCRIPT_URL) ./script.sh; chmod +x ./script.sh; ./script.sh"]
          env {
            name  = "S3_SCRIPT_URL"
            value = "s3://${aws_s3_bucket.vault-scripts.id}/scripts/bootstrap.sh"
          }
          env {
            name  = "VAULT_SECRET"
            value = aws_secretsmanager_secret.vault-secret.arn
          }
        }
        service_account_name = "boot-vault"
        restart_policy       = "Never"
      }
    }
    backoff_limit = 0
  }
  wait_for_completion = true
  timeouts {
    create = "5m"
    update = "5m"
  }

  depends_on = [
    kubernetes_job.vault-certificate,
    helm_release.vault,
    aws_s3_bucket_object.vault-script-bootstrap,
  ]
}

resource "kubernetes_job" "vault-certificate" {
  metadata {
    name      = "certificate-vault"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "certificate-vault"
          image   = "amazonlinux"
          command = ["/bin/bash", "-c"]
          args    = ["yum install -y awscli 2>&1 > /dev/null; export AWS_REGION=${var.region}; export NAMESPACE='vault'; aws sts get-caller-identity; aws s3 cp $(S3_SCRIPT_URL) ./script.sh; chmod +x ./script.sh; ./script.sh"]

          env {
            name  = "S3_SCRIPT_URL"
            value = "s3://${aws_s3_bucket.vault-scripts.id}/scripts/certificates.sh"
          }
        }
        service_account_name = "boot-vault"
        restart_policy       = "Never"
      }
    }
    backoff_limit = 0
  }

  wait_for_completion = true
  timeouts {
    create = "10m"
    update = "10m"
  }

  depends_on = [aws_s3_bucket_object.vault-script-certificates, aws_iam_role_policy.vault]
}

# Configure EKS RBAC
resource "kubernetes_cluster_role" "boot-vault" {
  metadata {
    name = "boot-vault"
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec", "pods", "pods/log", "secrets", "tmp/secrets"]
    verbs      = ["get", "list", "create"]
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests", "certificatesigningrequests/approval"]
    verbs      = ["get", "list", "create", "update", "approve"]
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups     = ["certificates.k8s.io"]
    resources      = ["signers"]
    resource_names = ["kubernetes.io/*"]
    verbs          = ["approve"]
  }
  depends_on = [kubernetes_namespace.vault]
}

resource "kubernetes_cluster_role_binding" "boot-vault" {
  metadata {
    name = "boot-vault"
    labels = {
      "app.kubernetes.io/name" : "boot-vault"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "boot-vault"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "boot-vault"
    namespace = "vault"
  }
  depends_on = [kubernetes_namespace.vault]
}

resource "kubernetes_service_account" "boot-vault" {
  metadata {
    name      = "boot-vault"
    namespace = "vault"
    labels = {
      "app.kubernetes.io/name" = "boot-vault"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.vault.arn
    }
  }
  depends_on = [resource.kubernetes_cluster_role.boot-vault, kubernetes_namespace.vault]
}

resource "helm_release" "consul" {
  name      = "consul"
  chart     = "hashicorp/consul"
  version   = "0.48.0"
  values    = [templatefile("consul-values.yaml", {})]
  namespace = "vault"

  depends_on = [kubernetes_job.vault-certificate, kubernetes_namespace.vault]
}

resource "helm_release" "vault" {
  name  = "vault"
  chart = "hashicorp/vault"
  values = [templatefile("vault-values.yaml", {
    env        = var.environment
    access_key = aws_iam_access_key.vault_kms.id
    secret_key = aws_iam_access_key.vault_kms.secret
    kms_key_id = aws_kms_key.vault-kms.key_id
  })]
  version    = "0.20.1"
  namespace  = "vault"
  depends_on = [kubernetes_job.vault-certificate, kubernetes_namespace.vault]
}



data "kubernetes_service" "vault-ui" {
  metadata {
    name      = "vault-ui"
    namespace = "vault"
  }
  depends_on = [
    kubernetes_job.vault-initialization,
    helm_release.vault,
  ]
}


resource "tls_private_key" "vault_private_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "vault_crt" {
  allowed_uses          = ["any_extended"]
  validity_period_hours = 365 * 24
  private_key_pem       = tls_private_key.vault_private_key.private_key_pem
  dns_names             = ["vault-lasdpc.icmc.usp.br"]

}

resource "kubernetes_secret" "vault_cert_secret" {
  metadata {
    namespace = kubernetes_namespace.vault.metadata[0].name
    name      = "tls-secret"
  }


  type = "kubernetes.io/tls"

  data = {
    "tls.key" : tls_private_key.vault_private_key.private_key_pem
    "tls.crt" : tls_self_signed_cert.vault_crt.cert_pem
  }
}

resource "kubernetes_ingress_v1" "ingress_vault" {
  metadata {
    annotations = {
      "kubernetes.io/ingress.class" : "nginx",
      "nginx.ingress.kubernetes.io/backend-protocol" : "HTTPS"
      "nginx.ingress.kubernetes.io/ssl-redirect" : "false"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" : "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
    name      = "vault-service-ingress"
    namespace = "vault"
  }
  spec {
    tls {
      hosts       = ["vault-lasdpc.icmc.usp.br"]
      secret_name = kubernetes_secret.vault_cert_secret.metadata[0].name
    }
    rule {
      host = "vault-lasdpc.icmc.usp.br"
      http {
        path {
          backend {
            service {
              name = "vault"
              port {
                number = 8200
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }
  depends_on = [helm_release.vault]
}
