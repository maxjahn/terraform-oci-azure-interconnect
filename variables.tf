
variable "enable_service_transit_routing"  {
    default = 1 
    description = "Enable OCI service transit routing, enabled by default"
}

variable "oci_compartment_ocid" {
    description = "OCID of OCI compartment to create interconnet in"
}

variable "oci_vcn_id" {
    description = "OCID of OCI VCN, to be set up outside this module"
}

variable "oci_fastconnect_bandwidth" {
    default = "1 Gbps"
    description = "Bandwidth for OCI FastConnect"
}

variable "oci_vcn_default_route_table_id" {
    description ="Default route table OCID for your VCN"
}

variable "oci_azure_provider_ocid" {
    description = "OCID of Azure FastConnect provider in the region you plan to setup the interconnect. Get that OCID by running the following command: oci network fast-connect-provider-service list --all --region your_region --compartment-id your_compartment_ocid"
}

variable "arm_resource_group_location" {
    description="Azure resource group location"
}

variable "arm_resource_group_name" {
    description="Azure resource group name"
}

variable "arm_expressroute_sku" {
    default ="Standard"
    description = "Azure ExpressRoute SKU, use UltraPerformance to enable fastpath"
}

variable "arm_expressroute_peering_location" {
    description="Peering location, get it from https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations"
}

variable "arm_expressroute_bandwidth" {
    default = 1000
    description = "Bandwidth in mbps for Azure ExpressRoute"
}

variable "arm_vnet_cidr" {  
    description = "CIDR block for the Azure VNet, to be set up outside this module"
}

variable "arm_gw_subnet_id" {
    description = "ID for Azure subnet to contain VNG, to be set up outside this module"
}

variable "peering_net" {
    default = "10.99.0.0/24"
    description = "/24 CIDR block to be used for peering"
}

locals {
  peering_net_prefix = trimsuffix(var.peering_net, ".0/24")
}

