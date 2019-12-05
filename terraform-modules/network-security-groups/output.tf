output "nsg_id" {
  value = join("", oci_core_network_security_group.nsg.*.id)
}

