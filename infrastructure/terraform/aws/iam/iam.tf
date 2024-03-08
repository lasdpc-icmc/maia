resource "aws_iam_user" "aws-usp" {
  count = length(var.username)
  name  = element(var.username, count.index)
}

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

resource "aws_iam_group_policy" "general_iam_group_policy" {
  name  = "GeneralIAMPolicy"
  group = aws_iam_group.general.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowGeneralUserActions",
        "Effect" : "Allow",
        "Action" : [
          "iam:DeactivateMFADevice",
          "iam:DeleteAccessKey",
          "iam:GetAccessKeyLastUsed",
          "iam:UpdateAccessKey",
          "iam:CreateVirtualMFADevice",
          "iam:UpdateSSHPublicKey",
          "iam:ListMFADevices",
          "iam:CreateAccessKey",
          "iam:DeleteVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:UploadSSHPublicKey",
          "iam:GetUser",
          "iam:ListMFADeviceTags",
          "iam:ChangePassword",
          "iam:ListAccessKeys"
        ],
        "Resource" : [
          "arn:aws:iam::${data.aws_caller_identity.this.account_id}:mfa/&{aws:username}",
          "arn:aws:iam::${data.aws_caller_identity.this.account_id}:sms-mfa/&{aws:username}",
          "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/&{aws:username}"
        ]
      },
      {
        "Sid" : "AllowViewPasswordPolicyAndMFADevices",
        "Effect" : "Allow",
        "Action" : [
          "iam:GetAccountPasswordPolicy",
          "iam:ListVirtualMFADevices"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_group_policy" "general_ec2_group_policy" {
  name  = "GeneralEC2Policy"
  group = aws_iam_group.general.name
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

resource "aws_iam_group_policy" "general_s3_group_policy" {
  name  = "GeneralS3Policy"
  group = aws_iam_group.general.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowReadAllForInfoBuckets",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetLifecycleConfiguration",
          "s3:GetBucketTagging",
          "s3:GetInventoryConfiguration",
          "s3:GetObjectVersionTagging",
          "s3:ListBucketVersions",
          "s3:GetBucketLogging",
          "s3:ListBucket",
          "s3:GetAccelerateConfiguration",
          "s3:GetObjectVersionAttributes",
          "s3:GetBucketPolicy",
          "s3:GetObjectVersionTorrent",
          "s3:GetObjectAcl",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetIntelligentTieringConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetMetricsConfiguration",
          "s3:GetBucketOwnershipControls",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketPolicyStatus",
          "s3:ListBucketMultipartUploads",
          "s3:GetObjectRetention",
          "s3:GetBucketWebsite",
          "s3:GetJobTagging",
          "s3:GetObjectAttributes",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:GetObjectLegalHold",
          "s3:GetBucketNotification",
          "s3:GetReplicationConfiguration",
          "s3:ListMultipartUploadParts",
          "s3:GetObject",
          "s3:GetObjectTorrent",
          "s3:DescribeJob",
          "s3:GetBucketCORS",
          "s3:GetAnalyticsConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion"
        ],
        "Resource" : [
          "arn:aws:s3:${var.region}:${data.aws_caller_identity.this.account_id}:job/*",
          "arn:aws:s3:::${var.bucket_states_name}",
          "arn:aws:s3:::${var.bucket_gatling_name}",
          "arn:aws:s3:::${var.bucket_locust_name}",
          "arn:aws:s3:::${var.bucket_states_name}/*",
          "arn:aws:s3:::${var.bucket_gatling_name}/*",
          "arn:aws:s3:::${var.bucket_locust_name}/*"
        ]
      },
      {
        "Sid" : "AllowListGeneralS3Info",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:ListJobs",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_group_policy" "general_eks_group_policy" {
  name  = "GeneralEKSPolicy"
  group = aws_iam_group.general.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowReadInfoEKS",
        "Effect" : "Allow",
        "Action" : [
          "eks:ListNodegroups",
          "eks:DescribeFargateProfile",
          "eks:ListTagsForResource",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:ListFargateProfiles",
          "eks:DescribeNodegroup",
          "eks:DescribeIdentityProviderConfig",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:ListIdentityProviderConfigs"
        ],
        "Resource" : [
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.this.account_id}:identityproviderconfig/*/*/*/*",
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.this.account_id}:fargateprofile/*/*/*",
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.this.account_id}:cluster/*",
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.this.account_id}:addon/*/*/*",
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.this.account_id}:nodegroup/*/*/*"
        ]
      },
      {
        "Sid" : "AllowListClustersAndAddonVersions",
        "Effect" : "Allow",
        "Action" : [
          "eks:ListClusters",
          "eks:DescribeAddonVersions"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_group_policy" "developers_s3_group_policy" {
  name  = "DevelopersS3Policy"
  group = aws_iam_group.developers.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowManageForInfoBuckets",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutAnalyticsConfiguration",
          "s3:PutAccelerateConfiguration",
          "s3:DeleteObjectVersion",
          "s3:RestoreObject",
          "s3:ReplicateObject",
          "s3:PutEncryptionConfiguration",
          "s3:AbortMultipartUpload",
          "s3:PutLifecycleConfiguration",
          "s3:UpdateJobPriority",
          "s3:DeleteObject",
          "s3:PutBucketVersioning",
          "s3:PutMetricsConfiguration",
          "s3:PutBucketOwnershipControls",
          "s3:PutReplicationConfiguration",
          "s3:PutObjectLegalHold",
          "s3:InitiateReplication",
          "s3:UpdateJobStatus",
          "s3:PutBucketCORS",
          "s3:PutInventoryConfiguration",
          "s3:PutObject",
          "s3:PutBucketNotification",
          "s3:PutBucketWebsite",
          "s3:PutBucketRequestPayment",
          "s3:PutObjectRetention",
          "s3:PutBucketLogging",
          "s3:PutBucketObjectLockConfiguration",
          "s3:ReplicateDelete"
        ],
        "Resource" : [
          "arn:aws:s3:${var.region}:${data.aws_caller_identity.this.account_id}:job/*",
          "arn:aws:s3:::${var.bucket_states_name}",
          "arn:aws:s3:::${var.bucket_gatling_name}",
          "arn:aws:s3:::${var.bucket_locust_name}",
          "arn:aws:s3:::${var.bucket_states_name}/*",
          "arn:aws:s3:::${var.bucket_gatling_name}/*",
          "arn:aws:s3:::${var.bucket_locust_name}/*"
        ]
      },
      {
        "Sid" : "AllowCreateJobs",
        "Effect" : "Allow",
        "Action" : "s3:CreateJob",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_group_membership" "general" {
  name = "general"

  users = var.username

  group = aws_iam_group.general.name
}

resource "aws_iam_group_membership" "dev" {
  name = "dev"

  users = var.username_dev

  group = aws_iam_group.developers.name
}

resource "aws_iam_group_membership" "read_only" {
  name = "read-only"

  users = var.username_read_only

  group = aws_iam_group.read_only.name
}

resource "aws_iam_role" "grafana_read_billing_role" {
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowReadingMetricsFromCloudWatch",
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${var.oidc_provider}"
        },
        "Action" : [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics", "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport",
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "tag:GetResources"
        ],
        "Resource" : "*",
        "Condition" = {
          "StringEquals" = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:monitoring:kube-prometheus-grafana"
          }
        }
      }
    ]
  })
}
