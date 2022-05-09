resource "aws_iam_user" "usp-eks-deploy" {
  name = "aws-eks-circleci"
}

resource "aws_iam_access_key" "usp-eks-deploy" {
  user = aws_iam_user.usp-eks-deploy.name
}

data "aws_iam_policy_document" "usp-eks-deploy" {
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

resource "aws_iam_user_policy" "usp-eks-deploy" {
  name   = "${terraform.workspace}-circleci-eks"
  user   = aws_iam_user.usp-eks-deploy.name
  policy = data.aws_iam_policy_document.usp-eks-deploy.json
}

output "secret" {
  value = aws_iam_access_key.usp-eks-deploy.secret
  sensitive = true
}