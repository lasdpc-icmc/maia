resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.default.id
  service_name    = "com.amazonaws.us-east-1.s3"
  route_table_ids = [aws_route_table.public.id, aws_route_table.private.id, aws_route_table.internal.id]
}