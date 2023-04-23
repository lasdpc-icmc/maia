resource "aws_s3_bucket" "terraform_state" {
  bucket = var.app_name
  tags   = local.common_tags
}

resource "aws_s3_bucket" "gatling_results" {
  bucket = var.app_gatling
  tags   = local.common_tags
}

resource "aws_s3_bucket" "locust_results" {
  bucket = var.app_locust
  tags   = local.common_tags
}

resource "aws_s3_bucket" "deeplog_results" {
  bucket = var.app_deeplog
  tags   = local.common_tags
}

resource "aws_s3_bucket" "thridy_party" {
  bucket = var.app_thirdparty
  tags   = local.common_tags
}