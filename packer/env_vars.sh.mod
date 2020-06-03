#!/bin/sh

# Required for the OCI Provider
export PACKER_availibilty_domain="IYfK:US-ASHBURN-AD-1"
export PACKER_compartment_ocid="ocid1.compartment.oc1..aaaaaaaadt4ydl2rxmw3hrx4cfq6zddadglrtls3c6fsbgwg4ktabije7e5q"
export PACKER_base_image_ocid="ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvt4jz4vc47qoc2ec4anha"
export PACKER_image_name="Compellon_2020_Image"
export PACKER_shape="VM.Standard2.1"
export PACKER_ssh_username="opc"
export PACKER_subnet_ocid="ocid1.subnet.oc1.iad.aaaaaaaagfwktuhlo7354aeyypbggrdzx6lxqqyypahaortekajusn6egzma"
export PACKER_type="oracle-oci"
export DOCKER_login="zekekaufman"
export DOCKER_pw="49d154f6-dde6-4cd1-8734-303f65bd2213"

# Keys used to SSH to OCI VMs
#export PACKER_ssh_public_key=$(cat ~/.ssh/oci.pub)
#export PACKER_ssh_private_key=$(cat ~/.ssh/oci)
