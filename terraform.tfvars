# AWS / Project Settings
aws_region   = "ap-northeast-2"
environment  = "prd"
project_name = "eks-cluster"
tags         = { CreatedBy = "Terraform" }

# Keycloak SAML Settings
saml_provider_name      = "KeycloakVPN"
saml_metadata_file_path = "./config/keycloak/idp-metadata.xml"

# Hub VPC Configuration (VPN이 배포되는 중앙 허브)
hub_vpc_id              = "vpc-xxxxxxxxx"          # Hub VPC ID
hub_vpc_cidr            = "10.0.0.0/16"            # Hub VPC CIDR
hub_primary_subnet_id   = "subnet-xxxxxxxxx"       # Hub VPC Subnet 1
hub_secondary_subnet_id = "subnet-yyyyyyyyy"       # Hub VPC Subnet 2
hub_route_table_id      = "rtb-xxxxxxxxx"          # Hub VPC Route Table

# VPN Settings
vpn_client_cidr_block  = "172.31.0.0/16"
split_tunnel_enabled   = true
connection_log_enabled = false
server_certificate_arn = "arn:aws:acm:ap-northeast-xxxx:certificate/xxxx"

# Spoke VPCs Configuration (Hub를 통해 접근할 격리된 환경들)
spoke_vpcs = {
  # "vpc-11111111" = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]   # DEV 환경
  # "vpc-22222222" = ["subnet-cccccccc", "subnet-dddddddd"]   # STG 환경
  # "vpc-33333333" = ["subnet-eeeeeeee", "subnet-ffffffff"]   # PRD 환경
}

# Spoke VPC CIDR (Hub에서 이 대역으로 라우팅)
spoke_vpc_cidrs = {
  # "vpc-11111111" = "10.1.0.0/16"   # DEV 환경
  # "vpc-22222222" = "10.2.0.0/16"   # STG 환경
  # "vpc-33333333" = "10.3.0.0/16"   # PRD 환경
}

# Spoke VPC Route Table IDs (각 Spoke에서 Hub로 라우팅 추가)
spoke_vpc_route_table_ids = {
  # "vpc-11111111" = "rtb-aaaaaaaa"   # DEV 환경 Route Table
  # "vpc-22222222" = "rtb-bbbbbbbb"   # STG 환경 Route Table
  # "vpc-33333333" = "rtb-cccccccc"   # PRD 환경 Route Table
}
