# root module - modules.tf
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
data "oci_core_images" "centos_image" {
  compartment_id = var.compartment_ocid
  operating_system = "Canonical Ubuntu"
  operating_system_version = "18.04"
  shape = "VM.Standard2.1"
  sort_by = "TIMECREATED"
}
module "devmachine" {
  source           = "./devmachine"
  compartment_ocid = var.compartment_ocid
  vcn_ocid         = oci_core_virtual_network.vcn.id
  vcn_igw_ocid     = oci_core_internet_gateway.igw.id
  vcn_cidr         = oci_core_virtual_network.vcn.cidr_block
  vcn_subnet_cidr  = "10.0.9.0/27"
  ads = data.oci_identity_availability_domains.ads.availability_domains[*].name
  image_ocid = data.oci_core_images.centos_image.images[0].id
}
module "functions" {
  source           = "./functions"
  compartment_ocid = var.compartment_ocid
  vcn_ocid         = oci_core_virtual_network.vcn.id
  vcn_natgw_ocid     = oci_core_nat_gateway.natgw.id
  vcn_cidr         = oci_core_virtual_network.vcn.cidr_block
  vcn_subnet_cidr  = "10.0.9.128/25"
}
output "dev_machine_public_ip" {
  value = module.devmachine.dev_public_ip
}
output "dev_machine_image_name" {
  value = data.oci_core_images.centos_image.images[0].display_name
}
output "functions_subnet_ocid" {
  value = module.functions.functions_subnet_ocid
}
