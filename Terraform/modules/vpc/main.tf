resource "aws_vpc" "ecs-v3" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true     
    enable_dns_support = true       

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
  for_each = { for k, v in local.subnets : k => v if v.public } 
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
  subnet_id = aws_subnet.subnets[each.key].id
}

resource "aws_vpc_endpoint" "Interface" { # creating elastic network interface for this vpc endpoint, usually has an endpoint attached
  for_each = local.vpc_endpoints
  vpc_id            = aws_vpc.ecs-v3.id
  service_name      = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ 
    for k, subnet in aws_subnet.subnets :
    subnet.id
    if !local.subnets[k].public
  ]
  security_group_ids = [var.vpc_endpoint_sg]
  private_dns_enabled = true 
  # Private DNS causes the standard AWS service hostname, to resolve to the endpoint's private IP addresses, allowing applications to use the normal configuration

}

# need to create vpc endpoint for s3 since ECR stores image layers in s3
# Gateway endpoints add routes on route tables directing traffic directly on network preventing internet connectivity
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.ecs-v3.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private-route-table.id]
}

# service discovery is required for the microservices to communicate via dns names
# the api-gateway routes to the services via dns but the names cannot be resolved 
resource "aws_service_discovery_private_dns_namespace" "ecs_discovery" {
  name        = "ecs.internal"
  description = "this creates an internal DNS zone like so: '*.ecs.internal' so now the ecs tasks can register dns entries e.g. dashboard-api.ecs.internal -> task-ip"
  vpc         = aws_vpc.ecs-v3.id
}

resource "aws_service_discovery_service" "ecs_tasks_dns_discovery" {
  for_each = local.service_discoveries
  name = each.value

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs_discovery.id

    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}