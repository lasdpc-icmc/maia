resource "aws_s3_bucket" "terraform_state" {
  bucket = var.app_name
  tags = local.common_tags
}