data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  resource_suffix = "ydhomelab"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [local.resource_suffix]
}

resource "azurerm_resource_group" "this" {
    name = module.naming.resource_group.name
    location = "westeurope"
}

resource "time_rotating" "service_principal_key_rotation" {
    rotation_months = 1
    lifecycle {
      create_before_destroy = true
    }
}

resource "azuread_application" "this" {
    display_name = "homelab-sp"
    owners = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "this" {
    client_id = azuread_application.this.client_id
}

resource "azuread_service_principal_password" "this" {
   service_principal_id =  azuread_service_principal.this.id
   rotate_when_changed = {
    rotation = time_rotating.service_principal_key_rotation.id
   }
   lifecycle {
     create_before_destroy = false
   }
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = module.naming.log_analytics_workspace.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_key_vault" "this" {
  name                        = module.naming.key_vault.name
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true
  public_network_access_enabled = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_role_assignment" "kv_admin" {
    role_definition_name = "Key Vault Administrator"
    principal_id = azuread_service_principal.this.object_id
    scope = azurerm_key_vault.this.id
}