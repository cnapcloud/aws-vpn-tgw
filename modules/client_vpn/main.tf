# SAML Provider
resource "aws_iam_saml_provider" "keycloak_vpn" {
  name                   = "keycloak-vpn-saml-${var.environment}"
  saml_metadata_document = file(var.saml_metadata_file_path)
  tags = {
    Name        = "keycloak-vpn-saml-provider"
    Environment = var.environment
  }
}

# Security Group for Hub VPC
# Note: Ingress rules not needed - Client VPN Endpoint manages inbound VPN connections automatically
resource "aws_security_group" "vpn_sg" {
  name_prefix = "keycloak-vpn-${var.environment}-"
  description = "Security group for Keycloak VPN in Hub VPC"
  vpc_id      = var.vpc_id

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "keycloak-vpn-sg-${var.environment}"
    Environment = var.environment
  }
}

# CloudWatch Log Group for Client VPN
resource "aws_cloudwatch_log_group" "vpn_logs" {
  count             = var.create_vpn_log_group ? 1 : 0
  name              = "/aws/clientvpn/keycloak-vpn-${var.environment}"
  retention_in_days = 30
  
  tags = {
    Name        = "keycloak-vpn-logs"
    Environment = var.environment
  }
}

# Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "keycloak" {
  description            = "Keycloak-based Client VPN Endpoint"
  client_cidr_block      = var.vpn_client_cidr_block
  server_certificate_arn = var.server_certificate_arn
  split_tunnel           = var.split_tunnel_enabled

  authentication_options {
    type              = "federated-authentication"
    saml_provider_arn = aws_iam_saml_provider.keycloak_vpn.arn
  }

  connection_log_options {
    enabled              = var.connection_log_enabled
    cloudwatch_log_group =  "/aws/clientvpn/keycloak-vpn-${var.environment}"
  }

  security_group_ids = [aws_security_group.vpn_sg.id]
  vpc_id             = var.vpc_id

  tags = {
    Name        = "keycloak-vpn-endpoint"
    Environment = var.environment
  }

  depends_on = [aws_iam_saml_provider.keycloak_vpn]
}

# Target Network Associations
resource "aws_ec2_client_vpn_network_association" "primary" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.keycloak.id
  subnet_id              = var.hub_primary_subnet_id
}

# Note: hub_secondary_subnet_id must be in a different AZ than hub_primary_subnet_id for HA
resource "aws_ec2_client_vpn_network_association" "secondary" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.keycloak.id
  subnet_id              = var.hub_secondary_subnet_id
}

# Authorization Rule - Hub VPC CIDR
resource "aws_ec2_client_vpn_authorization_rule" "vpc_access" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.keycloak.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
  description            = "Allow all users to Hub VPC"
  
  depends_on = [aws_ec2_client_vpn_network_association.primary]
}

# Authorization Rules - Spoke VPCs via TGW
resource "aws_ec2_client_vpn_authorization_rule" "spoke_vpcs" {
  for_each               = toset(var.spoke_vpc_cidrs_list)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.keycloak.id
  target_network_cidr    = each.value
  authorize_all_groups   = true
  description            = "Allow access to Spoke VPC ${each.value} via TGW"
  
  depends_on = [aws_ec2_client_vpn_network_association.primary]
}

# Routes - Spoke VPCs via TGW
# IMPORTANT: Split tunnel mode에서 route는 연결 시 동적으로 push됩니다
# 
# 초기 배포 후:
#   1. terraform apply 완료 후 1-2분 대기 (route가 active 상태가 되기까지)
#   2. AWS CLI로 route 상태 확인: aws ec2 describe-client-vpn-routes --client-vpn-endpoint-id <id>
#   3. 모든 route가 "active" 상태인지 확인
#   4. VPN 연결 (클라이언트가 최초 연결 시 route를 받음)
# 
# Route 변경 후 (spoke_vpc_cidrs_list 추가/삭제):
#   1. terraform apply로 route 변경
#   2. 모든 VPN 사용자는 반드시 재연결 필요 (새 route를 받기 위해)
#   3. 재연결하지 않으면 새로운 CIDR로 접근 불가
resource "aws_ec2_client_vpn_route" "spoke_vpcs" {
  for_each               = toset(var.spoke_vpc_cidrs_list)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.keycloak.id
  destination_cidr_block = each.value
  target_vpc_subnet_id   = var.hub_secondary_subnet_id
  description            = "Route to Spoke VPC ${each.value} via TGW"
  
  depends_on = [
    aws_ec2_client_vpn_network_association.primary,
    aws_ec2_client_vpn_network_association.secondary
  ]
}
