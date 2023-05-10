# terraform/resource-group.tf

# Import a previous created resource groups
data "azurerm_resource_group" "rg" {
  name = "rg-${var.service_name}${var.environment_suffix}"
}
