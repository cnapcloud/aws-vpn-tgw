# Transit Gateway 모듈 (Multi-VPC 환경에서만 생성)
module "transit_gateway" {
  source = "./modules/transit_gateway"

  # 기본 설정
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags

  # Hub-and-Spoke 설정
  spoke_vpcs                  = var.spoke_vpcs
  spoke_vpc_cidrs             = var.spoke_vpc_cidrs
  spoke_vpc_route_table_ids   = var.spoke_vpc_route_table_ids
  hub_vpc_id                  = var.hub_vpc_id
  hub_vpc_cidr                = var.hub_vpc_cidr
  hub_route_table_id          = var.hub_route_table_id
  hub_primary_subnet_id       = var.hub_primary_subnet_id
  hub_secondary_subnet_id     = var.hub_secondary_subnet_id
  vpn_client_cidr_block       = var.vpn_client_cidr_block
}

# Client VPN 모듈
module "client_vpn" {
  source = "./modules/client_vpn"

  # 기본 설정
  aws_region  = var.aws_region
  environment = var.environment

  # Keycloak SAML 인증
  saml_provider_name      = var.saml_provider_name
  saml_metadata_file_path = var.saml_metadata_file_path

  # Hub VPC 설정
  vpc_id                  = var.hub_vpc_id
  vpc_cidr                = var.hub_vpc_cidr
  hub_primary_subnet_id   = var.hub_primary_subnet_id
  hub_secondary_subnet_id = var.hub_secondary_subnet_id

  # VPN 클라이언트 설정
  vpn_client_cidr_block  = var.vpn_client_cidr_block
  server_certificate_arn = var.server_certificate_arn
  split_tunnel_enabled   = var.split_tunnel_enabled
  connection_log_enabled = var.connection_log_enabled

  # Transit Gateway 연동 (TGW가 생성된 경우)
  transit_gateway_id             = module.transit_gateway.transit_gateway_id
  transit_gateway_route_table_id = module.transit_gateway.transit_gateway_route_table_id

  # Spoke VPC CIDR 목록 (VPN에서 접근할 대상)
  spoke_vpc_cidrs_list = values(var.spoke_vpc_cidrs)

  depends_on = [module.transit_gateway]
}