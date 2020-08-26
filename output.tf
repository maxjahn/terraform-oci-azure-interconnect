output "interconnect_drg_id" {
  value = oci_core_drg.service_drg.id
  description = "OCID of OCI DRG used for interconnect."
}

output "interconnect_vng_id" {
  value = azurerm_virtual_network_gateway.conn_vng.id
  description = "ID of Azure VNG used for interconnect"
}

output "interconnect_az_gw_subnet_id" {
  value = azurerm_subnet.gateway_subnet.id
  description = "ID of Azure gateway subnet that has been created"
}



