
variable "enable_service_transit_routing"  {
    default = 1 
    description = "Enable OCI service transit routing, enabled by default"
    type = number

    # enable validation once this experimental feature is promoted to GA
    # validation {
    #     condition = var.enable_service_transit_routing == 0 || var.enable_service_transit_routing == 1
    #     error_message = "Value must be either 0 or 1. A value of 1 will enable transit routing."
    # }
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

variable "az_resource_group_name" {
    description="Azure resource group name"
}

variable "az_expressroute_sku" {
    default ="Standard"
    description = "Azure ExpressRoute SKU, use UltraPerformance to enable fastpath"
}

variable "az_expressroute_peering_location" {
    description="Peering location, get it from https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations"
}

variable "az_expressroute_bandwidth" {
    default = 1000
    description = "Bandwidth in mbps for Azure ExpressRoute"
}

variable "az_vnet_name" {  
    description = "Name of Azure VNet, to be set up outside this module"
}

variable "az_gw_subnet_cidr" {
    description = "CIDR for Azure subnet to contain VNG"
}

variable "interconnect_peering_net" {
    default = "10.99.0.0/24"
    description = "/24 CIDR block to be used for peering"
}

data "azurerm_virtual_network" "connect_vnet" {
  name                = var.az_vnet_name
  resource_group_name = var.az_resource_group_name
}

data "azurerm_resource_group" "connect_rg" {
  name = var.az_resource_group_name
}

data "oci_core_fast_connect_provider_services" "fcs" {
    compartment_id =  var.oci_compartment_ocid
}

locals {
  interconnect_peering_net_prefix = trimsuffix(var.interconnect_peering_net, ".0/24")
  az_resource_group_location = data.azurerm_resource_group.connect_rg.location
  oci_azure_provider_ocid = data.oci_core_fast_connect_provider_services.fcs.fast_connect_provider_services[index(data.oci_core_fast_connect_provider_services.fcs.fast_connect_provider_services.*.provider_name, "Microsoft Azure")].id

}






