locals {
  aso_subject = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
}

resource "azurerm_federated_identity_credential" "myworkload_identity" {
  name                = azurerm_user_assigned_identity.kubelet_identity.name
  resource_group_name = azurerm_user_assigned_identity.kubelet_identity.resource_group_name
  parent_id           = azurerm_user_assigned_identity.kubelet_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  subject             = local.aso_subject 
}