locals {
  # If ad_number is non-negative use it for AD lookup, else use ad_name.
  # Allows for use of ad_number in TF deploys, and ad_name in ORM.
  # Use of max() prevents out of index lookup call.
  ad = var.availability_domain_number >= 0 ? data.oci_identity_availability_domains.availability_domains.availability_domains[max(0, var.availability_domain_number)]["name"] : var.availability_domain_name

  # Platform OL7 image regarless of region
  platform_image = data.oci_core_images.ol7.images[0].id

  # Logic to choose platform or mkpl image based on
  # var.enabled
  image          = var.enabled ? var.mp_listing_resource_id : local.platform_image

  # local.use_existing_network defined in network.tf and referenced here
}

resource "oci_core_instance" "simple-vm" {
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = var.vm_compute_shape

  create_vnic_details {
    subnet_id        = local.use_existing_network ? var.subnet_id : oci_core_subnet.public_subnet[0].id
    display_name     = var.vm_display_name
    assign_public_ip = true
    hostname_label = "simple-vm"
  }

  source_details {
    source_type = "image"
    source_id   = local.image
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(file("./scripts/example.sh"))
  }

}
