# OCI-Azure-Interconnect

Use this module to easily add an OCI-Azure interconnect to your environment.

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
| arm\_expressroute\_bandwidth | Bandwidth in mbps for Azure ExpressRoute | `number` | `1000` | no |
| arm\_expressroute\_peering\_location | Peering location, get it from https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations | `any` | n/a | yes |
| arm\_expressroute\_sku | Azure ExpressRoute SKU, use UltraPerformance to enable fastpath | `string` | `"Standard"` | no |
| arm\_gw\_subnet\_id | ID for Azure subnet to contain VNG, to be set up outside this module | `any` | n/a | yes |
| arm\_resource\_group\_location | Azure resource group location | `any` | n/a | yes |
| arm\_resource\_group\_name | Azure resource group name | `any` | n/a | yes |
| arm\_vnet\_cidr | CIDR block for the Azure VNet, to be set up outside this module | `any` | n/a | yes |
| enable\_service\_transit\_routing | Enable OCI service transit routing, enabled by default | `number` | `1` | no |
| oci\_azure\_provider\_ocid | OCID of Azure FastConnect provider in the region you plan to setup the interconnect. Get that OCID by running the following command: oci network fast-connect-provider-service list --all --region your\_region --compartment-id your\_compartment\_ocid | `any` | n/a | yes |
| oci\_compartment\_ocid | OCID of OCI compartment to create interconnet in | `any` | n/a | yes |
| oci\_fastconnect\_bandwidth | Bandwidth for OCI FastConnect | `string` | `"1 Gbps"` | no |
| oci\_vcn\_default\_route\_table\_id | Default route table OCID for your VCN | `any` | n/a | yes |
| oci\_vcn\_id | OCID of OCI VCN, to be set up outside this module | `any` | n/a | yes |
| peering\_net | /24 CIDR block to be used for peering | `string` | `"10.99.0.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| interconnect\_drg\_id | OCID of OCI DRG used for interconnect. |
| interconnect\_vng\_id | ID of Azure VNG used for interconnect |
