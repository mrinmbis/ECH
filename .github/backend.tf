terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "yourtfstateacct"
    container_name       = "tfstate"
    key                  = "gitops-infra.tfstate"
  }
}
