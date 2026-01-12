output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.keycloak.id
}

output "client_vpn_endpoint_arn" {
  description = "ARN of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.keycloak.arn
}

output "client_vpn_dns_name" {
  description = "DNS name of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.keycloak.dns_name
}

output "client_vpn_client_cidr_block" {
  description = "Client CIDR block allocated for VPN clients"
  value       = aws_ec2_client_vpn_endpoint.keycloak.client_cidr_block
}

output "saml_provider_arn" {
  description = "ARN of the Keycloak SAML provider"
  value       = aws_iam_saml_provider.keycloak_vpn.arn
}

output "vpn_security_group_id" {
  description = "Security group ID for the VPN endpoint"
  value       = aws_security_group.vpn_sg.id
}

output "target_network_associations" {
  description = "Network association IDs for primary and secondary subnets"
  value = {
    primary   = aws_ec2_client_vpn_network_association.primary.id
    secondary = aws_ec2_client_vpn_network_association.secondary.id
  }
}

output "vpn_log_group_name" {
  description = "CloudWatch log group name for VPN connection logs"
  value       = var.create_vpn_log_group ? aws_cloudwatch_log_group.vpn_logs[0].name : null
}
