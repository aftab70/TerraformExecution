# Configure the Azure Providerr

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "AzureDevopsWithTerraform"
    storage_account_name = "terraformeastus"
    container_name       = "statefile"
  }
}
