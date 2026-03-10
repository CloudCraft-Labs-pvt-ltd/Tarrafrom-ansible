module "compute" {
  source = "./compute"
  resource_groups = var.resource_groups
    vnet = var.vnet
    subnet = var.subnet
    public_ip = var.public_ip
    network_interface = var.network_interface
    linux_virtual_machine = var.linux_virtual_machine
    subnet_nsg_assoc = var.subnet_nsg_assoc

}
output "vm_ip_addresses" {
  value = module.compute.vm_ip_addresses
}