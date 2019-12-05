#Local variables pointing to the Marketplace catalog resource
#Eg. Modify accordingly to your Application/Listing
locals {
  enabled                  = var.enabled ? 1 : 0
  listing_id               = var.mp_listing_id
  listing_resource_id      = var.mp_listing_resource_id
  listing_resource_version = var.mp_listing_resource_version
}

#Get Image Agreement 
resource "oci_core_app_catalog_listing_resource_version_agreement" "mp_image_agreement" {
  count = local.enabled

  listing_id               = local.listing_id
  listing_resource_version = local.listing_resource_version
}

#Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "mp_image_subscription" {
  count = local.enabled

  compartment_id           = var.compartment_id
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

# Gets the partner image subscription
data "oci_core_app_catalog_subscriptions" "mp_image_subscription" {
  count = local.enabled

  compartment_id = var.compartment_id
  listing_id     = local.listing_id

  filter {
    name   = "listing_resource_version"
    values = [local.listing_resource_version]
  }
}

