provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rgech" {
  name     = "rg-gitops-func"
  location = "East US"
}

resource "azurerm_storage_account" "sa" {
  name                     = "gitopsfuncstorage123" # Must be globally unique
  resource_group_name      = azurerm_resource_group.rgech.name
  location                 = azurerm_resource_group.rgech.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "code" {
  name                  = "functioncode"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_app_service_plan" "asp" {
  name                = "asp-gitops-func"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rgech.name
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_linux_function_app" "func" {
  name                       = "gitops-func-app"
  location                   = azurerm_resource_group.rgech.location
  resource_group_name        = azurerm_resource_group.rgech.name
  service_plan_id            = azurerm_app_service_plan.rgech.id
  storage_account_name       = azurerm_storage_account.rgech.name
  storage_account_access_key = azurerm_storage_account.rgech.primary_access_key

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    "AzureWebJobsStorage"        = azurerm_storage_account.sa.primary_connection_string
    "WEBSITE_RUN_FROM_PACKAGE"   = "1"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
  }
}
