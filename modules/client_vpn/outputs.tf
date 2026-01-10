output "saml_provider_arn" {
  description = "ARN of the Keycloak SAML provider"
  value       = aws_iam_saml_provider.keycloak_vpn.arn
}

output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.keycloak.id
}

output "client_vpn_endpoint_arn" {
  description = "ARN of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.keycloak.arn
}

output "vpn_security_group_id" {
  description = "Security group ID for the VPN endpoint"
  value       = aws_security_group.vpn_sg.id
}

output "client_vpn_client_cidr_block" {
  description = "Client CIDR block for VPN"
  value       = aws_ec2_client_vpn_endpoint.keycloak.client_cidr_block
}

output "target_network_associations" {
  description = "IDs of target network associations"
  value = {
    primary   = aws_ec2_client_vpn_network_association.primary.id
    secondary = try(aws_ec2_client_vpn_network_association.secondary[0].id, null)
  }
}
