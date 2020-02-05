
#https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html
resource "azurerm_virtual_network" "consulDemo" {
   name = var.virtual_network_name
   location = var.location
   resource_group_name = azurerm_resource_group.rg.name
   address_space = [ var.address_prefix ]

}
# https://www.terraform.io/docs/providers/azurerm/r/subnet.html
resource "azurerm_subnet" "k8s_subnet" {
   name = var.subnet_name
   address_prefix = var.address_prefix
   resource_group_name = azurerm_resource_group.rg.name
   virtual_network_name = azurerm_virtual_network.consulDemo.name   

}