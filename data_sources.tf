data "oci_core_images" "ol7" {
  compartment_id      = "${var.compartment_ocid}"
  operating_system    = "Oracle Linux"
  sort_by             = "TIMECREATED"
  sort_order          = "DESC"
  state               = "AVAILABLE"

  # filter restricts to pegged version regardless of region
  filter {
    name = "display_name"
    values = ["Oracle-Linux-7.7-2020.03.23-0"]
    regex = false
  }

  # filter restricts to OL 7
  filter {
    name = "operating_system_version"
    values = ["7\\.[0-9]"]
    regex = true
  }
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.compartment_ocid
}
