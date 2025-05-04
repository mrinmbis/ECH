provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rgech" {
  name     = "rg-gitops-func"
  location = "westus2"  # Ensured lowercase for region
}

# Storage Account (Updated Name)
resource "azurerm_storage_account" "sa" {
  name                     = "gitopsfuncstorageech"  # Updated storage account name
  resource_group_name      = azurerm_resource_group.rgech.name
  location                 = azurerm_resource_group.rgech.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage Container for Function Code
resource "azurerm_storage_container" "code" {
  name                  = "functioncode"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# App Service Plan for Function App
resource "azurerm_app_service_plan" "asp" {
  name                = "asp-gitops-func"
  location            = azurerm_resource_group.rgech.location
  resource_group_name = azurerm_resource_group.rgech.name
  kind                = "FunctionApp"

  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Linux Function App
resource "azurerm_linux_function_app" "func" {
  name                       = "gitops-func-app"
  location                   = azurerm_resource_group.rgech.location
  resource_group_name        = azurerm_resource_group.rgech.name
  service_plan_id            = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    "AzureWebJobsStorage"         = azurerm_storage_account.sa.primary_connection_string
    "WEBSITE_RUN_FROM_PACKAGE"    = "1"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
  }
}
