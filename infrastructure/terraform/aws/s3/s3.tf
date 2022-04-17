resource "aws_s3_bucket" "terraform_state" {
  bucket = var.app_name
  tags = local.common_tags
}

resource "aws_s3_bucket" "gatling_results" {
  bucket = var.app_gatling
  tags = local.common_tags
}