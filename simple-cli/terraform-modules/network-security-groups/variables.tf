variable "compartment_ocid" {
}

variable "vcn_id" {
}

variable "vcn_cidr_block" {
}

variable "nsg_display_name" {
}

variable "nsg_whitelist_ip" {
  default = ""
}

variable "use_existing_network" {
  type = bool
  default = false
}