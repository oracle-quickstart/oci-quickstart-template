
output "vcn_id" {
  value = !var.use_existing_network ? join("", oci_core_vcn.vcn.*.id) : var.vcn_id
}

output "subnet_id" {
  value = !var.use_existing_network ? join("", oci_core_subnet.public_subnet.*.id) : var.subnet_id
}

output "vcn_cidr_block" {
  value = !var.use_existing_network ? join("", oci_core_vcn.vcn.*.cidr_block) : var.vcn_cidr_block
}


