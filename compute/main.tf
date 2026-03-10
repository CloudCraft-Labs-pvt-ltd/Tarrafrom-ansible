resource "azurerm_resource_group" "rg" {
  for_each = var.resource_groups
  name     = each.value.name
  location = each.value.location

}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnet
  name                = each.value.name
  location            = each.value.location
  resource_group_name = var.resource_groups[each.value.rg_key].name
  address_space       = each.value.address_space
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnet
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.rg[each.value.rg_key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = each.value.address_prefix
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_public_ip" "public_ip" {
  for_each            = var.resource_groups
  name                = "${each.value.name}-public-ip"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_network_interface" "nic" {
  for_each = var.network_interface

  name                = each.value.name
  location            = azurerm_resource_group.rg[each.value.rg_key].location
  resource_group_name = azurerm_resource_group.rg[each.value.rg_key].name
  depends_on          = [azurerm_subnet.subnet]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.value.subnet_key].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.linux_virtual_machine

  name                = each.value.name
  location            = azurerm_resource_group.rg[each.value.rg_key].location
  resource_group_name = azurerm_resource_group.rg[each.value.rg_key].name
  size                = each.value.size
  admin_username      = each.value.admin_user
  admin_password      = each.value.admin_password
  depends_on          = [azurerm_network_interface.nic]
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[each.value.nic_key].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.resource_groups
  name                = "${each.value.name}-nsg"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  depends_on          = [azurerm_resource_group.rg]
  

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  for_each = var.subnet_nsg_assoc

  subnet_id                 = azurerm_subnet.subnet[each.value.subnet_key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_key].id
  depends_on                = [azurerm_network_security_group.nsg, azurerm_subnet.subnet]
}