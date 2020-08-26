# OCI-Azure-Interconnect

Use this module to easily add an OCI-Azure interconnect to your environment.

Prepare these resources to create the interconnect in:
- OCI compartment
- OCI VCN
- Azure resource group
- Azure VNet

Example (Amsterdam region):

module "interconnect" {  
 source = "./modules/interconnect"

  oci\_compartment\_ocid             = var.oci\_compartment\_ocid  
  oci\_vcn\_id                       = oci\_core\_virtual\_network.service\_vcn.id

  az\_resource\_group\_name           = "interconnect\_ams"  
  az\_vnet\_name                     = "interconnect\_vnet"  
  az\_gw\_subnet\_cidr                = "10.1.99.0/24"

  az\_expressroute\_peering\_location = "Amsterdam2"

  interconnect\_peering\_net         = "10.99.0.0/24"

  # optional  
  enable\_service\_transit\_routing   = 0  
  az\_expressroute\_sku              = "Standard"  
  az\_expressroute\_bandwidth        = 1000  
  oci\_fastconnect\_bandwidth        = "1 Gbps"
}

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |
| oci | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| az\_expressroute\_bandwidth | Bandwidth in mbps for Azure ExpressRoute | `number` | `1000` | no |
| az\_expressroute\_peering\_location | Peering location, get it from https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations | `any` | n/a | yes |
| az\_expressroute\_sku | Azure ExpressRoute SKU, use UltraPerformance to enable fastpath | `string` | `"Standard"` | no |
| az\_gw\_subnet\_cidr | CIDR for Azure subnet to contain VNG, to be set up outside this module | `any` | n/a | yes |
| az\_resource\_group\_name | Azure resource group name | `any` | n/a | yes |
| az\_vnet\_name | Name of Azure VNet, to be set up outside this module | `any` | n/a | yes |
| enable\_service\_transit\_routing | Enable OCI service transit routing, enabled by default | `number` | `1` | no |
| interconnect\_peering\_net | /24 CIDR block to be used for peering | `string` | `"10.99.0.0/24"` | no |
| oci\_compartment\_ocid | OCID of OCI compartment to create interconnet in | `any` | n/a | yes |
| oci\_fastconnect\_bandwidth | Bandwidth for OCI FastConnect | `string` | `"1 Gbps"` | no |
| oci\_vcn\_id | OCID of OCI VCN, to be set up outside this module | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| interconnect\_az\_gw\_subnet\_id | ID of Azure gateway subnet that has been created |
| interconnect\_drg\_id | OCID of OCI DRG used for interconnect. |
| interconnect\_vng\_id | ID of Azure VNG used for interconnect |
