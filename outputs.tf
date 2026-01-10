output "saml_provider_arn" {
  description = "ARN of the Keycloak SAML provider"
  value       = module.client_vpn.saml_provider_arn
}

output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = module.client_vpn.client_vpn_endpoint_id
}

output "client_vpn_endpoint_arn" {
  description = "ARN of the Client VPN endpoint"
  value       = module.client_vpn.client_vpn_endpoint_arn
}

output "vpn_security_group_id" {
  description = "Security group ID for the VPN endpoint"
  value       = module.client_vpn.vpn_security_group_id
}

output "client_vpn_client_cidr_block" {
  description = "Client CIDR block for VPN"
  value       = module.client_vpn.client_vpn_client_cidr_block
}

output "target_network_associations" {
  description = "IDs of target network associations"
  value       = module.client_vpn.target_network_associations
}
# Transit Gateway Outputs
output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_arn
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway Route Table"
  value       = module.transit_gateway.transit_gateway_route_table_id
}

output "vpc_attachments" {
  description = "Map of VPC attachments to Transit Gateway"
  value       = module.transit_gateway.vpc_attachments
}