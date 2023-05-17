provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

#App-Vnet
resource "azurerm_virtual_network" "example" {
  name = "App-vnet"
  location   = var.location
  resource_group_name = var.rg_name
  address_space = ["10.0.0.0/16"]
}

#Subnets of App Vnet
resource "azurerm_subnet" "example" {
  name  = "App-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "example2" {
  name  = "AppGW-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP for VM-with-Reverse-proxy
resource "azurerm_public_ip" "example" {
  name = "VM-with-Reverse-proxy-PIP"
  resource_group_name = var.rg_name
  location   = var.location
  allocation_method   = "Dynamic"
}

#VM-NSG
resource "azurerm_network_security_group" "example_nsg" {
  name= "VM-with-Reverse-proxy-nsg"
  location    = var.location
  resource_group_name = var.rg_name

  security_rule {
    name = "AllowSSH"
    priority   = 100
    direction  = "Inbound"
    access     = "Allow"
    protocol   = "Tcp"
    source_port_range  = "*"
    destination_port_range     = "22"
    source_address_prefix= "*"
    destination_address_prefix = "*"
    }

  security_rule {
    name = "AllowHTTP"
    priority   = 200
    direction  = "Inbound"
    access     = "Allow"
    protocol   = "Tcp"
    source_port_range  = "*"
    destination_port_range     = "80"
    source_address_prefix= "*"
    destination_address_prefix = "*"
  }
}

#NSG-NIC Association
resource "azurerm_network_interface_security_group_association" "example_nsg_association" {
  network_interface_id= azurerm_network_interface.example_nic.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}

resource "azurerm_network_interface" "example_nic" {
  name = "VM-with-Reverse-proxy-nic"
  location   = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name  = "testconfiguration1"
    subnet_id   = azurerm_subnet.example.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.1.4"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

#Create a VM
resource "azurerm_linux_virtual_machine" "example_linux_vm" {
  name= "VM-with-Reverse-proxy"
  location= var.location
  resource_group_name = var.rg_name
  size= "Standard_B1ls"

  network_interface_ids = [
    azurerm_network_interface.example_nic.id,
  ]
  admin_username = "anil5259"
  admin_password = "anil@1234567"
  disable_password_authentication = false

  os_disk {
    name = "vm-os-disk"
    caching= "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 40
  }

    source_image_reference {
    publisher = "Canonical"
    offer   = "UbuntuServer"
    sku    = "18.04-LTS"
    version  = "latest"
 }

}

resource "azurerm_dns_a_record" "dns_zone_record" {
  name= "salesforce-crm"
  zone_name   = var.dns_zone
  resource_group_name = var.rg_name
  ttl = 300
  target_resource_id  = azurerm_public_ip.example2.id
}

# Create Public IP accocited with AppGW

resource "azurerm_public_ip" "example2" {
  name = "AppGW-PIP"
  resource_group_name = var.rg_name
  location   = var.location
  sku = "Basic"
  allocation_method = "Dynamic"
}

# Create Application gateway

resource "azurerm_application_gateway" "example_application_gateway"{
  name = "AppGW"
  location = var.location
  resource_group_name = var.rg_name

  sku {
    name = "WAF_Medium"
    tier = "WAF"
    capacity = 2
  }

  gateway_ip_configuration {
    name   = "AppGW-ip-configuration"
    subnet_id = azurerm_subnet.example2.id
  }

 frontend_port {
  name = "myFrontendPort"
  port = 80
 }

 frontend_ip_configuration {
  name = "myAGIPConfig"
  #  subnet_id = azurerm_subnet.example2.id
   public_ip_address_id = azurerm_public_ip.example2.id
 }
 
 backend_address_pool {
  name = "example-backend-pool"
 }

 backend_http_settings {
  name = "myHTTPsetting"
  cookie_based_affinity = "Disabled"
  port = 80
  protocol = "Http"
  request_timeout = 20

 }

 http_listener {
  name     = "myListener"
  frontend_ip_configuration_name = "myAGIPConfig"
  frontend_port_name = "myFrontendPort"
  protocol   = "Http"
 }
 
 request_routing_rule {
  name   = "myRoutingRule"
  rule_type= "Basic"
  http_listener_name     = "myListener"
  backend_address_pool_name = "example-backend-pool"
  backend_http_settings_name = "myHTTPsetting"
 }

}

#Associate Backend pool with VM 's NIC
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.example_nic.id
  ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = tolist(azurerm_application_gateway.example_application_gateway.backend_address_pool).0.id
}



