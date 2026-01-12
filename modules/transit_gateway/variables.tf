variable "environment" {
  description = "Environment name (e.g., dev, stg, prd)"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "eks"
}

variable "tags" {
  description = "Common tags to apply to TGW resources"
  type        = map(string)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "spoke_vpcs" {
  description = "Map of Spoke VPC IDs to list of subnet IDs for TGW attachment (each VPC needs at least 2 subnets for multi-AZ)"
  type        = map(list(string))
  default     = {}

  validation {
    condition     = alltrue([for subnets in values(var.spoke_vpcs) : length(subnets) >= 2])
    error_message = "Each Spoke VPC must have at least 2 subnets for TGW attachment (multi-AZ requirement)."
  }
}

variable "spoke_vpc_cidrs" {
  description = "Map of Spoke VPC IDs to their CIDR blocks"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for cidr in values(var.spoke_vpc_cidrs) : can(cidrhost(cidr, 0))])
    error_message = "All Spoke VPC CIDRs must be valid CIDR blocks."
  }
}

variable "spoke_vpc_route_table_ids" {
  description = "Map of Spoke VPC IDs to list of route table IDs for adding TGW routes to Hub"
  type        = map(list(string))
  default     = {}
}

variable "hub_vpc_id" {
  description = "Hub VPC ID where VPN is deployed"
  type        = string
}

variable "hub_vpc_cidr" {
  description = "Hub VPC CIDR block"
  type        = string
}

variable "hub_route_table_ids" {
  description = "List of Hub VPC Route Table IDs for adding routes to Spoke VPCs"
  type        = list(string)
}

variable "hub_tgw_subnet_ids" {
  description = "List of Hub VPC subnet IDs for TGW attachment (minimum 2 for multi-AZ)"
  type        = list(string)
  
  validation {
    condition     = length(var.hub_tgw_subnet_ids) >= 2
    error_message = "Hub VPC must have at least 2 subnets for TGW attachment (multi-AZ requirement)."
  }
}

variable "vpn_client_cidr_block" {
  description = "VPN client CIDR block for routing configuration"
  type        = string
}

variable "create_tgw_log_group" {
  description = "Whether to create CloudWatch Log Group for TGW Flow Logs (set false if using existing log group)"
  type        = bool
  default     = true
}
