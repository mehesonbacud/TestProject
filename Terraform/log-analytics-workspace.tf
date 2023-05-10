# terraform/log-analytics-workspace.tf

# Create Log Analytics Workspace related to App insights
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.service_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  retention_in_days   = 30
}