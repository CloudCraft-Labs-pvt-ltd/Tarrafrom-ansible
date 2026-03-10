variable "resource_groups" {
  description = "A map of resource groups to create. The key is the name of the resource group, and the value is an object containing the location."
  type = map(object({
    name     = string
    location = string
  }))
}

variable "vnet" {
  description = "Virtual networks"
  type = map(object({
    name          = string
    address_space = list(string)
    location      = string
    rg_key        = string
  }))
}

variable "subnet" {
  type = map(object({
    name           = string
    address_prefix = list(string)
    vnet_key       = string
    rg_key         = string
  }))
}

variable "public_ip" {
  description = "A map of public IP addresses to create. The key is the name of the public IP address, and the value is an object containing the allocation method and location."
  type = map(object({
    name              = string
    allocation_method = string
    location          = string
  }))
}

variable "network_interface" {
  type = map(object({
    name       = string
    subnet_key = string
    rg_key     = string
  }))
}

variable "linux_virtual_machine" {
  type = map(object({
    name           = string
    size           = string
    nic_key        = string
    rg_key         = string
    admin_user     = string
    admin_password = string
  }))
}

variable "subnet_nsg_assoc" {
  type = map(object({
    subnet_key = string
    nsg_key    = string
  }))
}