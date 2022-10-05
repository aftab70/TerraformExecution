# Creating Azure resourse group.

resource "azurerm_resource_group" "Resourse_Group" {
  name     = "terraform-rg"
  location = "East US"


  tags = {
    environment = "Production",
    DeployedBy = "Terrafrom",
    CreatedBy = "Aftab"

  }
}


resource "azurerm_network_security_group" "Apache_NSG" {
  name                = "Apache_NSG"
  location            = azurerm_resource_group.Resourse_Group.location
  resource_group_name = azurerm_resource_group.Resourse_Group.name
}

resource "azurerm_network_security_rule" "HTTPS" {
  name                        = "HTTPS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Resourse_Group.name
  network_security_group_name = azurerm_network_security_group.Apache_NSG.name
}


resource "azurerm_network_security_rule" "Grafana" {
  name                        = "Grafana"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Resourse_Group.name
  network_security_group_name = azurerm_network_security_group.Apache_NSG.name

}


resource "azurerm_network_security_rule" "SSH" {
  name                        = "SSH"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Resourse_Group.name
  network_security_group_name = azurerm_network_security_group.Apache_NSG.name

}

resource "azurerm_network_security_rule" "HTTP" {
  name                        = "HTTP"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Resourse_Group.name
  network_security_group_name = azurerm_network_security_group.Apache_NSG.name

}




resource "azurerm_virtual_network" "Virtual_Network" {
  name                = "vnet"
  location            = azurerm_resource_group.Resourse_Group.location
  resource_group_name = azurerm_resource_group.Resourse_Group.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Production",
    DeployedBy = "Terrafrom",
    CreatedBy = "Aftab"

  }  

}

resource "azurerm_subnet" "Default_Subnet" {
  name                 = "Default_Subnet"
  resource_group_name  = azurerm_resource_group.Resourse_Group.name
  virtual_network_name = azurerm_virtual_network.Virtual_Network.name
  address_prefixes     = ["10.0.0.0/24"]
}


resource "azurerm_subnet" "ScalSet_Subnet" {
  name                 = "ScalSet_Subnet"
  resource_group_name  = azurerm_resource_group.Resourse_Group.name
  virtual_network_name = azurerm_virtual_network.Virtual_Network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "AppGw_Subnet" {
  name                 = "AppGw_Subnet"
  resource_group_name  = azurerm_resource_group.Resourse_Group.name
  virtual_network_name = azurerm_virtual_network.Virtual_Network.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "WebApp-PIP" {
  name                = "WebApp-PIP"
  resource_group_name = azurerm_resource_group.Resourse_Group.name
  location            = azurerm_resource_group.Resourse_Group.location
  allocation_method   = "Static"

  tags = {
    environment = "Production",
    DeployedBy  = "Terraform",
    CreatedBy   = "Aftab"
  }
}



resource "azurerm_network_interface" "WebApp-nic" {
  name                = "WebApp-nic"
  location            = azurerm_resource_group.Resourse_Group.location
  resource_group_name = azurerm_resource_group.Resourse_Group.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.Default_Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.WebApp-PIP.id
  }
}

resource "azurerm_network_interface_security_group_association" "AssociationWithNIC" {
  network_interface_id      = azurerm_network_interface.WebApp-nic.id
  network_security_group_id = azurerm_network_security_group.Apache_NSG.id
}


resource "azurerm_virtual_machine" "WebApp" {
  name                  = "WebApp"
  location              = azurerm_resource_group.Resourse_Group.location
  resource_group_name   = azurerm_resource_group.Resourse_Group.name
  network_interface_ids = [azurerm_network_interface.WebApp-nic.id]
  vm_size               = "Standard_B1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "WebApp"
    admin_username = "aftab70"
    admin_password = "administrator@123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Production",
    CreatedBy   = "Aftab",
    DeployedBy  = "Terrafrom"
  }
}


/* resource "azurerm_virtual_machine_extension" "ScriptExecution" {
  name                 = "ScriptExecution"
  virtual_machine_id   = azurerm_virtual_machine.WebApp.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
     "script": "${filebase64("docker.sh")}"
    }
SETTINGS


  tags = {
    environment = "Production",
    DeployedBy  = "Terraform",
    CreatedBy   = "Aftab"
  } 
}
*/