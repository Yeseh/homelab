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
    tls = {
      source  = "hashicorp/tls"
      version = "=4.0.6"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.26.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.0-beta2"
    }
    time = {
      source  = "hashicorp/time"
      version = "=0.12.1"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    flux = {
      source = "fluxcd/flux"
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

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.this.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.this.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.cluster_ca_certificate)
  load_config_file       = "false"
}

provider "flux" {
  kubernetes = {
    host                   = azurerm_kubernetes_cluster.this.kube_admin_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.cluster_ca_certificate)
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.github_repo}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}