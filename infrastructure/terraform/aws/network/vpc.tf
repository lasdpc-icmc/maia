resource "aws_vpc" "default" {
  cidr_block = var.cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(local.common_tags, tomap({ "Name" = "${var.env}-${var.resource_name}-vpc" }))

}

resource "aws_subnet" "public" {
  count      = var.subnet["public"]
  depends_on = [aws_internet_gateway.default]
  vpc_id     = aws_vpc.default.id

  availability_zone       = element(slice(data.aws_availability_zones.available.names, 0, "${var.zones}"), count.index % length(slice(data.aws_availability_zones.available.names, 0, "${var.zones}")))
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, var.newbits, count.index + var.start_cidr_at)

  tags = merge(local.common_tags, tomap({ "Name" = "public-subnet-${var.env}-${var.resource_name}-${count.index + 1}" }))

}

resource "aws_subnet" "private" {
  count  = var.subnet["private"]
  vpc_id = aws_vpc.default.id

  availability_zone = element(slice(data.aws_availability_zones.available.names, 0, "${var.zones}"), (count.index % length(slice(data.aws_availability_zones.available.names, 0, "${var.zones}"))))
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, var.newbits, count.index + var.start_cidr_at + var.subnet["public"])

  tags = merge(local.common_tags, tomap({ "Name" = "private-subnet-${var.env}-${var.resource_name}-${count.index + 1}" }))
}

resource "aws_internet_gateway" "default" {
  vpc_id     = aws_vpc.default.id
  depends_on = [aws_vpc.default]

  tags = merge(local.common_tags, tomap({ "Name" = "internet-gw-${var.env}-${var.resource_name}" }))
}

resource "aws_eip" "nat_gateway" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.default, aws_subnet.public]
}

resource "aws_subnet" "internal" {
  count  = var.subnet["internal"]
  vpc_id = aws_vpc.default.id

  availability_zone       = element(slice(data.aws_availability_zones.available.names, 0, "${var.zones}"), count.index % length(slice(data.aws_availability_zones.available.names, 0, "${var.zones}")))
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, var.newbits, count.index + var.start_cidr_at + var.subnet["private"] + var.subnet["public"])

  tags = merge(local.common_tags, tomap({ "Name" = "internal-subnet-${var.env}-${var.resource_name}-${count.index + 1}" }))
}