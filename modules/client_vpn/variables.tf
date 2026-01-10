variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "saml_provider_name" {
  description = "Name of the SAML provider"
  type        = string
  default     = "KeycloakVPN"
}

variable "saml_metadata_file_path" {
  description = "Path to the SAML metadata XML file"
  type        = string
}

variable "vpc_id" {
  description = "Hub VPC ID where Client VPN will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "Hub VPC CIDR block"
  type        = string
}

variable "hub_primary_subnet_id" {
  description = "Hub VPC primary subnet ID for Client VPN target network"
  type        = string
}

variable "hub_secondary_subnet_id" {
  description = "Hub VPC secondary subnet ID for Client VPN target network (optional, for HA)"
  type        = string
  default     = null
}

variable "vpn_client_cidr_block" {
  description = "CIDR block for VPN client IP allocation (must not overlap with VPC CIDR)"
  type        = string
  default     = "10.100.0.0/22"
}

variable "server_certificate_arn" {
  description = "ARN of the server certificate from ACM for Client VPN endpoint"
  type        = string
}

variable "split_tunnel_enabled" {
  description = "Enable split tunneling for VPN client"
  type        = bool
  default     = true
}

variable "connection_log_enabled" {
  description = "Enable connection logging for VPN endpoint"
  type        = bool
  default     = false
}

variable "spoke_vpc_cidrs_list" {
  description = "List of Spoke VPC CIDRs to route via TGW"
  type        = list(string)
  default     = []
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID for routing VPN traffic"
  type        = string
  default     = null
}

variable "transit_gateway_route_table_id" {
  description = "Transit Gateway Route Table ID for VPN routing"
  type        = string
  default     = null
}
