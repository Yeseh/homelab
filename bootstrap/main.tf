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

### Keyvault

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

resource "azurerm_key_vault_secret" "deployment_client_id" {
  key_vault_id = azurerm_key_vault.this.id
  name = "homelab--config--deploymentClientId"
  value = azurerm_user_assigned_identity.kubelet_identity.client_id 
}

resource "azurerm_key_vault_secret" "platform_subscription_id" {
  key_vault_id = azurerm_key_vault.this.id
  name = "homelab--config--platformSubscriptionId"
  value = data.azurerm_client_config.current.subscription_id
}

resource "azurerm_key_vault_secret" "platform_tenant_id" {
  key_vault_id = azurerm_key_vault.this.id
  name = "homelab--config--platformTenantId"
  value = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_secret" "cluster_oidc_issuer_url" {
  key_vault_id = azurerm_key_vault.this.id
  name = "homelab--config--clusterOidcIssuerUrl"
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url 
}

### RBAC
resource "azuread_group" "homelab_management" {
  display_name = "homelab-management"
  owners = [
    data.azurerm_client_config.current.object_id,
    azurerm_user_assigned_identity.kubelet_identity.principal_id
  ]
  members = [
    data.azurerm_client_config.current.object_id,
    azurerm_user_assigned_identity.kubelet_identity.principal_id
  ]
  security_enabled = true
}

resource "azurerm_role_assignment" "keyvault_admin" {
  role_definition_name = "Key Vault Administrator"
  principal_id = azurerm_user_assigned_identity.kubelet_identity.principal_id
  scope = azurerm_key_vault.this.id
}

resource "azurerm_role_assignment" "subscription_owner" {
  role_definition_name = "Owner"
  principal_id = azuread_group.homelab_management.object_id 
  scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
}