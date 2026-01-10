# Transit Gateway Module

이 모듈은 AWS Transit Gateway를 설정하고, VPN을 경유해서 VPC로 들어가는 네트워크 구성을 제공합니다.

## 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                    Transit Gateway                       │
│  ┌────────────────────────────────────────────────────┐ │
│  │         TGW Route Table (Main)                     │ │
│  └────────────────────────────────────────────────────┘ │
└────────────┬─────────────────────────┬──────────────────┘
             │                         │
             │                         │
    ┌────────▼────────┐        ┌──────▼──────────┐
    │  VPN Attachment │        │ VPC Attachments │
    │  (Client VPN)   │        │  (future)       │
    └─────────────────┘        └─────────────────┘
             │
             ▼
    ┌─────────────────┐
    │  VPN Endpoint   │
    │ (172.31.0.0/16) │
    └─────────────────┘
             │
             ▼
    ┌─────────────────────────────────────┐
    │      VPC (10.0.0.0/16, etc.)       │
    │  ┌──────────┐      ┌──────────┐   │
    │  │ Private  │      │ Public   │   │
    │  │ Subnets  │      │ Subnets  │   │
    │  └──────────┘      └──────────┘   │
    └─────────────────────────────────────┘
```

## 리소스

- **Transit Gateway**: 중앙 허브 역할
- **Transit Gateway Route Table**: 라우팅 규칙 관리
- **Transit Gateway Attachments**: VPN 및 VPC 연결
- **Transit Gateway Routes**: CIDR 기반 라우팅

## 주요 특징

- VPN을 통한 안전한 접근
- 다중 VPC 연결 지원 (향후 확장)
- DNS 지원 활성화
- VPN ECN 지원 활성화

## 사용 예시

```hcl
module "transit_gateway" {
  source = "./modules/transit_gateway"

  aws_region             = "ap-northeast-2"
  environment            = "production"
  project_name           = "eks"
  enable_vpn_attachment  = true
  vpn_cidr              = "172.31.0.0/16"
}
```

## 확장

향후 VPC를 추가할 때는 다음과 같이 작성합니다:

```hcl
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_primary" {
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  vpc_id             = aws_vpc.primary.id
  subnet_ids         = aws_subnet.primary[*].id

  tags = {
    Name = "tgw-vpc-primary-attachment"
  }
}
```
