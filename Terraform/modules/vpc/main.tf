resource "aws_vpc" "ecs-v3" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true     # required for VPC endpoints to work
    enable_dns_support = true       # required for VPC endpoints to work

    tags = {
      Name = "${local.name}-vpc"
    }
}

resource "aws_subnet" "subnets" {
    vpc_id = aws_vpc.ecs-v3.id
    for_each = local.subnets
    cidr_block = each.value.cidr
    availability_zone = each.value.az
    map_public_ip_on_launch = each.value.public


    tags = {
      Name = "${local.name}-${each.key}"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs-v3.id

  tags = {
    Name = "${local.name}-igw"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.ecs-v3.id

  route {
    cidr_block = var.public_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  for_each = { for k, v in local.subnets : k => v if v.public } # Filter local.subnets down to only public subnets and loop over the result

  route_table_id = aws_route_table.public-route-table.id
  subnet_id = aws_subnet.subnets[each.key].id
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.ecs-v3.id

  tags = {
    Name = "${local.name}-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  for_each = { for k, v in local.subnets : k => v if !v.public }
  route_table_id = aws_route_table.private-route-table.id
  subnet_id = aws_subnet.subnets[each.key].id # loops through each key in the locals block to associate each subnet, the for_each block already identified which subnets to use
}

# resource "aws_vpc_endpoint" "ecs-service-1" {
#   vpc_id       = aws_vpc.ecs-v3.id
#   service_name = ""

#   tags = {
#     Name = "${local.name}-endpoint-1"
#   }
# }