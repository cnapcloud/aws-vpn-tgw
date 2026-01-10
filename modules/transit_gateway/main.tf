# Transit Gateway (Hub-and-Spoke)
resource "aws_ec2_transit_gateway" "main" {
  count                           = length(var.spoke_vpcs) > 0 ? 1 : 0
  description                     = "Transit Gateway for ${var.environment} (Hub-and-Spoke)"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-tgw-${var.environment}"
    Environment = var.environment
  })
}

# Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "main" {
  count              = length(var.spoke_vpcs) > 0 ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.main[0].id

  tags = merge(var.tags, {
    Name        = "${var.project_name}-tgw-rt-${var.environment}"
    Environment = var.environment
  })
}

# TGW Attachment for Hub VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "hub_vpc" {
  count              = length(var.spoke_vpcs) > 0 ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.main[0].id
  vpc_id             = var.hub_vpc_id
  subnet_ids         = var.hub_secondary_subnet_id != null ? [
    var.hub_primary_subnet_id,
    var.hub_secondary_subnet_id
  ] : [var.hub_primary_subnet_id]

  tags = merge(var.tags, {
    Name        = "${var.project_name}-tgw-attachment-hub"
    Environment = var.environment
    VPCRole     = "Hub"
  })
}

# TGW Attachments for Spoke VPCs
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_vpcs" {
  for_each           = length(var.spoke_vpcs) > 0 ? var.spoke_vpcs : {}
  transit_gateway_id = aws_ec2_transit_gateway.main[0].id
  vpc_id             = each.key
  subnet_ids         = each.value

  tags = merge(var.tags, {
    Name        = "${var.project_name}-tgw-attachment-spoke-${each.key}"
    Environment = var.environment
    VPCRole     = "Spoke"
  })
}

# Route Table Association & Propagation for Hub
resource "aws_ec2_transit_gateway_route_table_association" "hub_vpc" {
  count                          = length(var.spoke_vpcs) > 0 ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "hub_vpc" {
  count                          = length(var.spoke_vpcs) > 0 ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}

# Route Table Association & Propagation for Spokes
resource "aws_ec2_transit_gateway_route_table_association" "spoke_vpcs" {
  for_each                       = length(var.spoke_vpcs) > 0 ? aws_ec2_transit_gateway_vpc_attachment.spoke_vpcs : {}
  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_vpcs" {
  for_each                       = length(var.spoke_vpcs) > 0 ? aws_ec2_transit_gateway_vpc_attachment.spoke_vpcs : {}
  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}

# VPC Route Tables: Hub-and-Spoke topology
# Hub VPC ↔ Spoke VPCs 통신만 허용, Spoke VPCs 간 격리
locals {
  # Hub → All Spoke VPCs
  hub_to_spokes = length(var.spoke_vpcs) > 0 ? [
    for spoke_vpc_id, spoke_cidr in var.spoke_vpc_cidrs : {
      route_table_id = var.hub_route_table_id
      target_cidr    = spoke_cidr
      route_key      = "hub-to-${spoke_vpc_id}"
    }
  ] : []
  
  # Spoke VPCs → Hub only
  spokes_to_hub = length(var.spoke_vpcs) > 0 ? [
    for spoke_vpc_id, route_table_id in var.spoke_vpc_route_table_ids : {
      route_table_id = route_table_id
      target_cidr    = var.hub_vpc_cidr
      route_key      = "${spoke_vpc_id}-to-hub"
    }
  ] : []
  
  # 모든 라우트 결합
  vpc_routes = concat(local.hub_to_spokes, local.spokes_to_hub)
}

# VPC Route: Hub-and-Spoke routing
resource "aws_route" "vpc_hub_spoke" {
  for_each = length(var.spoke_vpcs) > 0 ? {
    for route in local.vpc_routes : route.route_key => route
  } : {}

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.target_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main[0].id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.hub_vpc,
    aws_ec2_transit_gateway_vpc_attachment.spoke_vpcs
  ]
}
