
locals {
  use_existing_network = var.network_strategy == "Use Existing VCN and Subnet" ? true : false
}

# VCN comes with default route table, security list and DHCP options

resource "oci_core_vcn" "vcn" {
  count          = local.use_existing_network ? 0:1
  cidr_block     = var.vcn_cidr_block
  dns_label      = var.vcn_dns_label
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
}

resource "oci_core_internet_gateway" "igw" {
  count          = local.use_existing_network ? 0:1
  compartment_id = var.compartment_ocid
  display_name   = "internet_gateway"
  vcn_id         = oci_core_vcn.vcn[count.index].id
}

resource "oci_core_default_route_table" "default_route_table" {
  count          = local.use_existing_network ? 0:1
  manage_default_resource_id = oci_core_vcn.vcn[count.index].default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[count.index].id
  }
}


resource "oci_core_subnet" "public_subnet" {
  count          = local.use_existing_network ? 0:1
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn[count.index].id
  cidr_block                 = var.subnet_cidr_block
  display_name               = var.subnet_display_name
  route_table_id             = oci_core_vcn.vcn[count.index].default_route_table_id
  dns_label                  = var.subnet_dns_label
  prohibit_public_ip_on_vnic = "false"
}

resource "oci_core_network_security_group" "nsg" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.vcn[0].id

  #Optional
  display_name = var.nsg_display_name
}

resource "oci_core_network_security_group_security_rule" "rule_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id

  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_tcp443" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_whitelist_ip != "" ? var.nsg_whitelist_ip : "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_all_icmp_type3_code4" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  protocol                  = 1
  direction                 = "INGRESS"
  source                    = var.nsg_whitelist_ip != "" ? var.nsg_whitelist_ip : "0.0.0.0/0"
  stateless                 = true

  icmp_options {
    type = 3
    code = 4
  }
}
