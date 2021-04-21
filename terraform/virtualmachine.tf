provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "epam-wordpress-rg" {
  name     = "epam-wordpress-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "epam-network" {
  name                = "epam-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.epam-wordpress-rg.location
  resource_group_name = azurerm_resource_group.epam-wordpress-rg.name
}

resource "azurerm_subnet" "epam-subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.epam-wordpress-rg.name
  virtual_network_name = azurerm_virtual_network.epam-network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "epam-nic" {
  name                = "epam-nic"
  location            = azurerm_resource_group.epam-wordpress-rg.location
  resource_group_name = azurerm_resource_group.epam-wordpress-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.epam-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "epam-vm" {
  name                = "epam-vm"
  resource_group_name = azurerm_resource_group.epam-wordpress-rg.name
  location            = azurerm_resource_group.epam-wordpress-rg.location
  size                = "Standard_F2"
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.epam-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}