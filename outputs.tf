# =============================================================================
# Client VPN Outputs
# =============================================================================

output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = module.client_vpn.client_vpn_endpoint_id
}

output "client_vpn_endpoint_arn" {
  description = "ARN of the Client VPN endpoint"
  value       = module.client_vpn.client_vpn_endpoint_arn
}

output "client_vpn_dns_name" {
  description = "DNS name of the Client VPN endpoint for OVPN configuration"
  value       = module.client_vpn.client_vpn_dns_name
}

output "client_vpn_client_cidr_block" {
  description = "Client CIDR block allocated for VPN clients"
  value       = module.client_vpn.client_vpn_client_cidr_block
}

output "saml_provider_arn" {
  description = "ARN of the Keycloak SAML provider for authentication"
  value       = module.client_vpn.saml_provider_arn
}

output "vpn_security_group_id" {
  description = "Security group ID attached to the VPN endpoint"
  value       = module.client_vpn.vpn_security_group_id
}

output "target_network_associations" {
  description = "Network association IDs (primary and secondary subnets)"
  value       = module.client_vpn.target_network_associations
}

output "vpn_log_group_name" {
  description = "CloudWatch log group name for VPN connection logs"
  value       = module.client_vpn.vpn_log_group_name
}

# =============================================================================
# Transit Gateway Outputs
# =============================================================================

output "transit_gateway_id" {
  description = "ID of the Transit Gateway (null if no spoke VPCs)"
  value       = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway (null if no spoke VPCs)"
  value       = module.transit_gateway.transit_gateway_arn
}

output "transit_gateway_route_table_id" {
  description = "ID of the custom Transit Gateway route table (null if no spoke VPCs)"
  value       = module.transit_gateway.transit_gateway_route_table_id
}

output "vpc_attachments" {
  description = "Hub and spoke VPC attachments to Transit Gateway"
  value       = module.transit_gateway.vpc_attachments
}