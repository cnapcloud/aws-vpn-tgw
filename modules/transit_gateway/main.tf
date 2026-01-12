# Transit Gateway (Hub-and-Spoke)
resource "aws_ec2_transit_gateway" "main" {
  count                           = length(var.spoke_vpcs) > 0 ? 1 : 0
  description                     = "Transit Gateway for ${var.environment} (Hub-and-Spoke)"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(var.tags, {
    Name        = "tgw-${var.environment}"
    Environment = var.environment
  })
}

# CloudWatch Log Group for Transit Gateway Flow Logs
resource "aws_cloudwatch_log_group" "tgw_flow_logs" {
  count             = length(var.spoke_vpcs) > 0 && var.create_tgw_log_group ? 1 : 0
  name              = "/aws/tgw/tgw-flow-logs-${var.environment}"
  retention_in_days = 30

  tags = {
    Name        = "tgw-flow-logs"
    Environment = var.environment
  }
}

# IAM Role for Transit Gateway Flow Logs
resource "aws_iam_role" "tgw_flow_log_role" {
  count = length(var.spoke_vpcs) > 0 && var.create_tgw_log_group ? 1 : 0
  name  = "tgw-log-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Transit Gateway Flow Log Role
resource "aws_iam_role_policy" "tgw_flow_log_policy" {
  count = length(var.spoke_vpcs) > 0 && var.create_tgw_log_group ? 1 : 0
  name  = "tgw-log-policy-${var.environment}"
  role  = aws_iam_role.tgw_flow_log_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.tgw_flow_logs[0].arn}:*"
    }]
  })
}

# Transit Gateway Flow Log for network traffic monitoring
resource "aws_flow_log" "tgw_log" {
  count                   = length(var.spoke_vpcs) > 0 && var.create_tgw_log_group ? 1 : 0
  iam_role_arn            = aws_iam_role.tgw_flow_log_role[0].arn
  log_destination         = aws_cloudwatch_log_group.tgw_flow_logs[0].arn
  log_destination_type    = "cloud-watch-logs"
  traffic_type            = "ALL"
  transit_gateway_id      = aws_ec2_transit_gateway.main[0].id
  max_aggregation_interval = 60

  tags = merge(var.tags, {
    Name        = "tgw-${var.environment}"
    Environment = var.environment
  })
}

# Transit Gateway Route Table for Hub-and-Spoke routing
resource "aws_ec2_transit_gateway_route_table" "main" {
  count              = length(var.spoke_vpcs) > 0 ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.main[0].id

  tags = merge(var.tags, {
    Name        = "tgw-rt-${var.environment}"
    Environment = var.environment
  })
}

# Transit Gateway VPC Attachment for Hub VPC (where VPN is deployed)
resource "aws_ec2_transit_gateway_vpc_attachment" "hub_vpc" {
  count              = length(var.spoke_vpcs) > 0 ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.main[0].id
  vpc_id             = var.hub_vpc_id
  subnet_ids         = var.hub_tgw_subnet_ids

  tags = merge(var.tags, {
    Name        = "tgw-attachment-hub"
    Environment = var.environment
    VPCRole     = "Hub"
  })
}

# Transit Gateway VPC Attachments for all Spoke VPCs
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_vpcs" {
  for_each           = length(var.spoke_vpcs) > 0 ? var.spoke_vpcs : {}
  transit_gateway_id = aws_ec2_transit_gateway.main[0].id
  vpc_id             = each.key
  subnet_ids         = each.value

  tags = merge(var.tags, {
    Name        = "tgw-attachment-spoke-${each.key}"
    Environment = var.environment
    VPCRole     = "Spoke"
  })
}

# Associate Hub VPC attachment with Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table_association" "hub_vpc" {
  count                          = length(var.spoke_vpcs) > 0 ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}
# Propagate Hub VPC routes to Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "hub_vpc" {
  count                          = length(var.spoke_vpcs) > 0 ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}

# Associate Spoke VPC attachments with Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_vpcs" {
  for_each                       = length(var.spoke_vpcs) > 0 ? aws_ec2_transit_gateway_vpc_attachment.spoke_vpcs : {}
  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}
# Propagate Spoke VPC routes to Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_vpcs" {
  for_each                       = length(var.spoke_vpcs) > 0 ? aws_ec2_transit_gateway_vpc_attachment.spoke_vpcs : {}
  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}

# Transit Gateway Route Table에 VPN 클라이언트 대역 등록 (필수 - return traffic용)
resource "aws_ec2_transit_gateway_route" "vpn_client" {
  count                          = length(var.spoke_vpcs) > 0 ? 1 : 0
  destination_cidr_block         = var.vpn_client_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main[0].id
}

# VPC Route Tables: Hub-and-Spoke topology
# Hub VPC ↔ Spoke VPCs 통신만 허용, Spoke VPCs 간 격리
locals {
  # Hub → All Spoke VPCs (모든 Hub route table에 추가)
  hub_to_spokes = length(var.spoke_vpcs) > 0 ? flatten([
    for route_table_id in var.hub_route_table_ids : [
      for spoke_vpc_id, spoke_cidr in var.spoke_vpc_cidrs : {
        route_table_id = route_table_id
        target_cidr    = spoke_cidr
        route_key      = "hub-${route_table_id}-to-${spoke_vpc_id}"
      }
    ]
  ]) : []
  
  # Spoke VPCs → Hub VPC
  spokes_to_hub = length(var.spoke_vpcs) > 0 ? flatten([
    for spoke_vpc_id, route_table_ids in var.spoke_vpc_route_table_ids : [
      for route_table_id in route_table_ids : {
        route_table_id = route_table_id
        target_cidr    = var.hub_vpc_cidr
        route_key      = "${spoke_vpc_id}-${route_table_id}-to-hub"
      }
    ]
  ]) : []
  
  # Spoke VPCs → VPN Client CIDR (for return traffic)
  spokes_to_vpn_client = length(var.spoke_vpcs) > 0 ? flatten([
    for spoke_vpc_id, route_table_ids in var.spoke_vpc_route_table_ids : [
      for route_table_id in route_table_ids : {
        route_table_id = route_table_id
        target_cidr    = var.vpn_client_cidr_block
        route_key      = "${spoke_vpc_id}-${route_table_id}-to-vpn-client"
      }
    ]
  ]) : []
  
  # 모든 라우트 결합
  vpc_routes = concat(local.hub_to_spokes, local.spokes_to_hub, local.spokes_to_vpn_client)
}

# VPC Routes for Hub-and-Spoke communication via Transit Gateway
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
