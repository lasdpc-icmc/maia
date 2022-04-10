output "vpc_id" {
  value = aws_vpc.default.id
}

output "cidr_block" {
  value = aws_vpc.default.cidr_block
}

output "priv_sn_id" {
  value = aws_subnet.private.*.id
}

output "priv_az" {
  value = aws_subnet.private.*.availability_zone
}

output "pub_sn_id" {
  value = aws_subnet.public.*.id
}

output "pub_az" {
  value = aws_subnet.public.*.availability_zone
}

output "int_sn_id" {
  value = aws_subnet.internal.*.id
}

output "int_az" {
  value = aws_subnet.internal.*.availability_zone
}
