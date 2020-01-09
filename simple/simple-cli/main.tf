## Subscribe to Marketplace listing
module "marketplace_subscription" {
  source         = "./terraform-modules/marketplace-subscription"
  compartment_id = var.compartment_ocid
  //listing id
  mp_listing_id = var.mp_listing_id
  //listing resource version (app version)
  mp_listing_resource_version = var.mp_listing_resource_version
  //image ocid
  mp_listing_resource_id = var.mp_listing_resource_id
}

## Creates a VCN with a public subnet and default IGW and Route Table
module "default_vcn_plus_subnet" {
  source              = "./terraform-modules/vcn-plus-subnet-default"
  compartment_ocid    = var.compartment_ocid
  vcn_display_name    = var.vcn_display_name
  vcn_cidr_block      = var.vcn_cidr_block
  vcn_dns_label       = var.vcn_dns_label
  subnet_display_name = var.subnet_display_name
  subnet_cidr_block   = var.subnet_cidr_block
  subnet_dns_label    = var.subnet_dns_label
}

## Allow Ingress HTTPS from 
module "default_network_sec_group" {
  source           = "./terraform-modules/network-security-groups"
  compartment_ocid = var.compartment_ocid
  nsg_display_name = var.nsg_display_name
  nsg_whitelist_ip = var.nsg_whitelist_ip
  vcn_id           = module.default_vcn_plus_subnet.vcn_id
  vcn_cidr_block   = var.vcn_cidr_block
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain_number
}

resource "oci_core_instance" "simple-vm" {
  depends_on = [module.marketplace_subscription]

  availability_domain = (var.availability_domain_name != "" ? var.availability_domain_name : data.oci_identity_availability_domain.ad.name)
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = var.vm_compute_shape

  create_vnic_details {
    subnet_id        = module.default_vcn_plus_subnet.subnet_id
    display_name     = var.vm_display_name
    assign_public_ip = true
    nsg_ids          = [module.default_network_sec_group.nsg_id]
  }

  source_details {
    source_type = "image"
    source_id   = var.mp_listing_resource_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }


}

output "instance_public_ip" {
  value = oci_core_instance.simple-vm.public_ip
}

output "instance_private_ip" {
  value = oci_core_instance.simple-vm.private_ip
}

output "instance_https_url" {
  value = "https://${oci_core_instance.simple-vm.public_ip}"
}

