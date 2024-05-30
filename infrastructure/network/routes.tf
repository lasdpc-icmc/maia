resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  depends_on = [aws_internet_gateway.default]


}

resource "aws_route_table_association" "public" {
  count          = var.subnet["public"]
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default.id
  }

  depends_on = [aws_internet_gateway.default]


}

resource "aws_route_table_association" "private" {
  count          = var.subnet["private"]
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "internal" {
  vpc_id = aws_vpc.default.id


}
