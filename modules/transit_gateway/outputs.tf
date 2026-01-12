output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = try(aws_ec2_transit_gateway.main[0].id, null)
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = try(aws_ec2_transit_gateway.main[0].arn, null)
}

output "transit_gateway_route_table_id" {
  description = "ID of the custom Transit Gateway route table"
  value       = try(aws_ec2_transit_gateway_route_table.main[0].id, null)
}

output "vpc_attachments" {
  description = "VPC attachments to Transit Gateway"
  value = {
    hub_vpc = try({
      id                = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].id
      vpc_id            = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].vpc_id
      subnet_ids        = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].subnet_ids
      transit_gateway_id = aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0].transit_gateway_id
    }, null)
    spoke_vpcs = { for k, v in aws_ec2_transit_gateway_vpc_attachment.spoke_vpcs : k => {
      id                = v.id
      vpc_id            = v.vpc_id
      subnet_ids        = v.subnet_ids
      transit_gateway_id = v.transit_gateway_id
    }}
  }
}
