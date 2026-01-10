output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = length(var.spoke_vpcs) > 0 ? aws_ec2_transit_gateway.main[0].id : null
}

output "transit_gateway_arn" {
  description = "The ARN of the Transit Gateway"
  value       = length(var.spoke_vpcs) > 0 ? aws_ec2_transit_gateway.main[0].arn : null
}

output "transit_gateway_route_table_id" {
  description = "The ID of the Transit Gateway Route Table"
  value       = length(var.spoke_vpcs) > 0 ? aws_ec2_transit_gateway_route_table.main[0].id : null
}

output "vpc_attachments" {
  description = "Map of VPC attachments (hub and spokes)"
  value = {
    hub_vpc    = length(var.spoke_vpcs) > 0 && length(aws_ec2_transit_gateway_vpc_attachment.hub_vpc) > 0 ? aws_ec2_transit_gateway_vpc_attachment.hub_vpc[0] : null
    spoke_vpcs = length(var.spoke_vpcs) > 0 ? aws_ec2_transit_gateway_vpc_attachment.spoke_vpcs : {}
  }
}
