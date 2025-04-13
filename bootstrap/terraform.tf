terraform {
  required_version = ">= 1.10.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.23"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.3"
    }
  }

  backend "azurerm" {
    use_azuread_auth = true 
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  storage_use_azuread = true
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
