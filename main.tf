/**
 * # OCI-Azure-Interconnect
 * 
 * Use this module to easily add an OCI-Azure interconnect to your environment.
 *
 * Prepare these resources to create the interconnect in:
 * - OCI compartment
 * - OCI VCN 
 * - Azure resource group
 * - Azure VNet 
 *
 *
 * Example (Amsterdam region):
 * 
 * ```
 * module "interconnect" {
 * source  = "maxjahn/azure-interconnect/oci"
 * version = "1.0.0"
 *   
 *   oci_compartment_ocid             = var.oci_compartment_ocid
 *   oci_vcn_id                       = oci_core_virtual_network.service_vcn.id
 * 
 *   az_resource_group_name           = "interconnect_ams"
 *   az_vnet_name                     = "interconnect_vnet"
 *   az_gw_subnet_cidr                = "10.1.99.0/24"
 * 
 *   az_expressroute_peering_location = "Amsterdam2"
 *   
 *   interconnect_peering_net         = "10.99.0.0/24"
 *   
 *   # optional
 *   enable_service_transit_routing   = 0
 *   az_expressroute_sku              = "Standard"
 *   az_expressroute_bandwidth        = 1000
 *   oci_fastconnect_bandwidth        = "1 Gbps"
 * }
 *
 * ```
 */


## oci setup

resource "oci_core_drg" "service_drg" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "service-drg"
}

resource "oci_core_drg_attachment" "service_drg_attachment" {
  drg_id         = oci_core_drg.service_drg.id
  vcn_id         = var.oci_vcn_id
  display_name   = "service-drg-attachment"
  route_table_id = var.enable_service_transit_routing == 0 ? "" : oci_core_route_table.service_gw_route_table[0].id
}

resource "oci_core_virtual_circuit" "interconnect_virtual_circuit" {
  display_name         = "interconnect-virtual-circuit"
  compartment_id       = var.oci_compartment_ocid
  gateway_id           = oci_core_drg.service_drg.id
  type                 = "PRIVATE"
  bandwidth_shape_name = var.oci_fastconnect_bandwidth

  provider_service_id       = local.oci_azure_provider_ocid
  provider_service_key_name = azurerm_express_route_circuit.connect_erc.service_key

# the peering ips are chosen arbitrarily, you always can pick other /30s if you do not like the range I used
  cross_connect_mappings {
    oracle_bgp_peering_ip   = "${local.interconnect_peering_net_prefix}.201/30"
    customer_bgp_peering_ip = "${local.interconnect_peering_net_prefix}.202/30"
  }

  cross_connect_mappings {
    oracle_bgp_peering_ip   = "${local.interconnect_peering_net_prefix}.205/30"
    customer_bgp_peering_ip = "${local.interconnect_peering_net_prefix}.206/30"
  }
}

resource "oci_core_route_table" "interconnect_route_table" {
  display_name   = "interconnect-route-table"
  compartment_id = var.oci_compartment_ocid
  vcn_id         = var.oci_vcn_id

  route_rules {
    network_entity_id = oci_core_drg.service_drg.id
    destination       = data.azurerm_virtual_network.connect_vnet.address_space[0]
  }
}

## oci service transit routing
data "oci_core_services" "transit_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "transit_service_gateway" {
  count = var.enable_service_transit_routing
  compartment_id = var.oci_compartment_ocid

  services {
    service_id = data.oci_core_services.transit_services.services[0]["id"]
  }
  vcn_id         = var.oci_vcn_id
  display_name   = "transitServiceGateway"
}

resource "oci_core_route_table" "service_gw_route_table" {
  count = var.enable_service_transit_routing
  display_name   = "service-gw-route-table"
  compartment_id = var.oci_compartment_ocid
  vcn_id         = var.oci_vcn_id

  route_rules {
    destination       = data.oci_core_services.transit_services.services[0]["cidr_block"]
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.transit_service_gateway[0].id
  }
}

## azure setup
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.az_resource_group_name
  virtual_network_name = var.az_vnet_name
  address_prefixes     = [var.az_gw_subnet_cidr]
}

resource "azurerm_express_route_circuit" "connect_erc" {
  name                  = "oci-connect-expressroute"
  resource_group_name   = var.az_resource_group_name
  location              = local.az_resource_group_location
  service_provider_name = "Oracle Cloud FastConnect"
  peering_location      = var.az_expressroute_peering_location
  bandwidth_in_mbps     = var.az_expressroute_bandwidth

  sku {
    tier   = "Local"
    family = "MeteredData"
  }

  allow_classic_operations = false
}

resource "azurerm_public_ip" "connect_vng_ip" {
  name                = "connect-vng-ip"
  location            = local.az_resource_group_location
  resource_group_name = var.az_resource_group_name
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "connect_vng_ip" {
  name                = azurerm_public_ip.connect_vng_ip.name
  resource_group_name = var.az_resource_group_name
}

resource "azurerm_virtual_network_gateway" "conn_vng" {
  name                = "connect-vng"
  location            = local.az_resource_group_location
  resource_group_name = var.az_resource_group_name
  type                = "ExpressRoute"
  enable_bgp          = true
  sku                 = var.az_expressroute_sku

  ip_configuration {
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
    public_ip_address_id          = azurerm_public_ip.connect_vng_ip.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "conn_vng_gw" {
  name                = "connect-vng-gw"
  location            = local.az_resource_group_location
  resource_group_name = var.az_resource_group_name

  type                         = "ExpressRoute"
  virtual_network_gateway_id   = azurerm_virtual_network_gateway.conn_vng.id
  express_route_circuit_id     = azurerm_express_route_circuit.connect_erc.id
  express_route_gateway_bypass = var.az_expressroute_sku == "UltraPerformance" ? true : false
}



