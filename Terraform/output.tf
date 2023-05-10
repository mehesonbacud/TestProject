# terraform/outputs.tf

# Verify the results
# Define an output value in output.tf file
# Execute the following command in a console
#   echo "$(terraform output resource_group_name)"

output "app_service_name" {
  value       = azurerm_linux_web_app.as.name
  description = "Deployed Web App Service name"
}

output "app_resource_group_name" {
  value       = data.azurerm_resource_group.rg.name
  description = "Imported Resource Group name"
}
