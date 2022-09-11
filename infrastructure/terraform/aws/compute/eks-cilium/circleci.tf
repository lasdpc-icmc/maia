resource "aws_iam_user" "usp-eks-deploy-cilium" {
  name = "${var.workspace}-aws-eks-circleci"
}

resource "aws_iam_access_key" "usp-eks-deploy-cilium" {
  user = aws_iam_user.usp-eks-deploy-cilium.name
}

data "aws_iam_policy_document" "usp-eks-deploy-cilium" {
  statement {
    sid       = "VisualEditor1"
    actions   = ["eks:*"]
    resources = [module.aws_eks.cluster_arn]
  }
  statement {
    sid       = "VisualEditor0"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "usp-eks-deploy-cilium" {
  name   = "${terraform.workspace}-circleci-eks"
  user   = aws_iam_user.usp-eks-deploy-cilium.name
  policy = data.aws_iam_policy_document.usp-eks-deploy-cilium.json
}

output "secret" {
  value = aws_iam_access_key.usp-eks-deploy-cilium.secret
  sensitive = true
}