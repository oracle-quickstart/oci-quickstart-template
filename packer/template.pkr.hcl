
variable "availibilty_domain" {
  type    = string
  default = env("PACKER_availibilty_domain")
}

variable "base_image_ocid" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaazavxtitjiojkyivwwb72pn2vcvnoxirpgkhf26i2ku4egieknkxq"
  # Oracle-Linux-8.7-2023.04.25-0
  # ocid1.image.oc1.iad.aaaaaaaazavxtitjiojkyivwwb72pn2vcvnoxirpgkhf26i2ku4egieknkxq
}

variable "compartment_ocid" {
  type    = string
  default = env("PACKER_compartment_ocid")
}

variable "my_secret" {
  type    = string
  default = env("PACKER_my_secret")
}

variable "shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}

variable "ocpus" {
  type    = number
  default = 2
}

variable "ssh_username" {
  type    = string
  default = "opc"
}

variable "subnet_ocid" {
  type    = string
  default = env("PACKER_subnet_ocid")
}

variable "type" {
  type    = string
  default = "oracle-oci"
}

variable "skip_image" {
  type    = bool
  default = false
}

variable "imgprefix" {
  type    = string
  default = "mybuild"
}

locals {
  timestamp     = regex_replace(timestamp(), "[- TZ:]", "")
  is_flex_shape = substr(var.shape, -5, -1) == ".Flex" ? [1] : []
}

packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

source "oracle-oci" "builder_vm" {
  image_name          = "${var.imgprefix}-${var.shape}-${local.timestamp}"
  availability_domain = var.availibilty_domain
  base_image_ocid     = var.base_image_ocid
  compartment_ocid    = var.compartment_ocid
  shape               = var.shape
  ssh_username        = var.ssh_username
  subnet_ocid         = var.subnet_ocid

  dynamic "shape_config" {
    for_each = local.is_flex_shape
    content {
      ocpus = var.ocpus
    }
  }

  skip_create_image = var.skip_image
}

build {
  sources = ["source.oracle-oci.builder_vm"]

  provisioner "shell" {
    expect_disconnect = "true"
    inline            = ["cd ~", "echo Hello World!", "echo ${var.my_secret} > /dev/null", "touch foobar.txt"]
  }

  provisioner "shell" {
    script = "installer.sh"
  }

  provisioner "file" {
    source      = "README.md"
    destination = "~/test_file"
  }

  provisioner "shell" {
    script = "cleanup.sh"
  }

}
