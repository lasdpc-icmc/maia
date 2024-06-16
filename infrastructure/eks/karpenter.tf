resource "aws_iam_role" "nodes" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = [ "system:serviceaccount:karpenter:karpenter" ]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json
  name               = "karpenter-controller"
  depends_on = [
    data.aws_iam_policy_document.karpenter_controller_assume_role_policy
  ]
}

resource "aws_iam_policy" "karpenter_controller" {
  policy = jsonencode({
    Statement = [{
      "Action" : [
        "ssm:GetParameter",
        "iam:PassRole",
        "ec2:RunInstances",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeAvailabilityZones",
        "ec2:DeleteLaunchTemplate",
        "ec2:CreateTags",
        "ec2:CreateLaunchTemplate",
        "ec2:CreateFleet",
        "ec2:DescribeSpotPriceHistory",
        "ec2:TerminateInstances",
        "pricing:GetProducts",
      ],
      "Effect" : "Allow",
      "Resource" : "*",
      "Sid" : "Karpenter"
      },
      {
        "Action" : "ec2:TerminateInstances",
        "Condition" : {
          "StringLike" : {
            "ec2:ResourceTag/managed-by" : "karpenter"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "ConditionalEC2Termination"
      }
    ]
    Version = "2012-10-17"
  })
  name       = "KarpenterController"
  depends_on = [aws_iam_role.karpenter_controller]
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
  depends_on = [aws_iam_policy.karpenter_controller]
}

resource "aws_iam_instance_profile" "karpenter" {
  name       = "KarpenterNodeInstanceProfile"
  role       = aws_iam_role.nodes.name
  depends_on = [aws_iam_role_policy_attachment.aws_load_balancer_controller_attach]
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint,
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
  ]
  url             = flatten(concat(aws_eks_cluster.eks_cluster[*].identity[*].oidc.0.issuer, [""]))[0]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

####################
## Helm karpenter ##
####################

