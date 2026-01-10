# AWS 기본 설정
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, stg, prd)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "eks"
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    CreatedBy = "Terraform"
  }
}

# Transit Gateway - Spoke VPC 설정 (Hub-and-Spoke 아키텍처)
variable "spoke_vpcs" {
  description = "Map of Spoke VPC IDs to list of subnet IDs for TGW attachment (each VPC needs at least 2 subnets)"
  type        = map(list(string))
  default     = {}

  validation {
    condition     = alltrue([for subnets in values(var.spoke_vpcs) : length(subnets) >= 2])
    error_message = "Each Spoke VPC must have at least 2 subnets for TGW attachment (multi-AZ requirement)."
  }
}

variable "spoke_vpc_cidrs" {
  description = "Map of Spoke VPC IDs to their CIDR blocks for routing configuration"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for cidr in values(var.spoke_vpc_cidrs) : can(cidrhost(cidr, 0))])
    error_message = "All Spoke VPC CIDRs must be valid CIDR blocks."
  }
}

variable "spoke_vpc_route_table_ids" {
  description = "Map of Spoke VPC IDs to their route table IDs for adding TGW routes"
  type        = map(string)
  default     = {}
}

# Hub VPC 설정 (VPN이 배포되는 중앙 허브)
variable "hub_vpc_id" {
  description = "Hub VPC ID where Client VPN endpoint will be deployed"
  type        = string
}

variable "hub_vpc_cidr" {
  description = "Hub VPC CIDR block"
  type        = string
}

variable "hub_route_table_id" {
  description = "Hub VPC Route Table ID for adding routes to Spoke VPCs"
  type        = string
}

variable "hub_primary_subnet_id" {
  description = "Hub VPC primary subnet for Client VPN ENI"
  type        = string
}

variable "hub_secondary_subnet_id" {
  description = "Hub VPC secondary subnet for Client VPN ENI (HA)"
  type        = string
  default     = null
}

# VPN 클라이언트 설정
variable "vpn_client_cidr_block" {
  description = "VPN Client CIDR block (must not overlap with VPC CIDRs)"
  type        = string
  default     = "172.31.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpn_client_cidr_block, 0))
    error_message = "VPN client CIDR block must be a valid CIDR."
  }
}

variable "server_certificate_arn" {
  description = "ARN of the ACM certificate for the VPN endpoint"
  type        = string
}

variable "split_tunnel_enabled" {
  description = "Enable split-tunnel for Client VPN"
  type        = bool
  default     = true
}

variable "connection_log_enabled" {
  description = "Enable VPN connection logging"
  type        = bool
  default     = false
}

# Keycloak SAML 인증
variable "saml_provider_name" {
  description = "Name of the SAML provider for Keycloak VPN authentication"
  type        = string
}

variable "saml_metadata_file_path" {
  description = "Path to the SAML metadata XML file for Keycloak"
  type        = string
}
