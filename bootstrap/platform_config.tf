locals {
  platform_namespace = "platform-system"
  platform_externalsecrets_sa_name = "externalsecrets-platform"
  aso_subject = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
  eso_subject = "system:serviceaccount:${local.platform_namespace}:${local.platform_externalsecrets_sa_name}"
}

resource "azurerm_user_assigned_identity" "platform_deployment" {
  name                = "${module.naming.user_assigned_identity.name}-platform-deployment"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_role_assignment" "platform_subscription_owner" {
  role_definition_name = "Owner"
  scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  principal_id = azurerm_user_assigned_identity.platform_deployment.principal_id
}

resource "azurerm_federated_identity_credential" "azure_service_operator" {
  name                = azurerm_user_assigned_identity.platform_deployment.name
  resource_group_name = azurerm_user_assigned_identity.platform_deployment.resource_group_name
  parent_id           = azurerm_user_assigned_identity.platform_deployment.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  subject             = local.aso_subject 
}

resource "azurerm_user_assigned_identity" "external_secrets_operator" {
  name                = "${module.naming.user_assigned_identity.name}-platform-secrets-operator"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_federated_identity_credential" "external_secrets_operator" {
  name                = azurerm_user_assigned_identity.external_secrets_operator.name
  resource_group_name = azurerm_user_assigned_identity.external_secrets_operator.resource_group_name
  parent_id           = azurerm_user_assigned_identity.external_secrets_operator.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  subject             = local.eso_subject 
}

resource "kubectl_manifest" "platform_configmap" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: platform-bootstrap
  namespace: flux-system 
  labels:
    platform/managed-by: bootstrap
data:
  platformKeyvaultUri: ${azurerm_key_vault.this.vault_uri}
  platformTenantId: "${data.azurerm_client_config.current.tenant_id}"
  platformSubscriptionId: "${data.azurerm_client_config.current.subscription_id}"
  platformNamespace: "${local.platform_namespace}"
  platformExternalSecretsServiceAccountName: "${local.platform_externalsecrets_sa_name}"
  platformExternalSecretsClientId: "${azurerm_user_assigned_identity.external_secrets_operator.client_id}"
  platformDeploymentClientId: "${azurerm_user_assigned_identity.platform_deployment.client_id}"
YAML
  depends_on = [ azurerm_kubernetes_cluster.this ]
}
