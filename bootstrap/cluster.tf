resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

resource "random_integer" "cluster_services_cidr" {
  min = 64
  max = 99
}

resource "random_integer" "cluster_pod_cidr" {
  min = 100
  max = 127
}

locals {
  vnet_cidr                     = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  cluster_nodes_subnet_cidr     = cidrsubnet(local.vnet_cidr, 8, 2)
  cluster_api_subnet_cidir      = cidrsubnet(local.vnet_cidr, 12, 1)
}

resource "azurerm_user_assigned_identity" "cluster_identity" {
  name                = "${module.naming.user_assigned_identity.name}-cluster"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_user_assigned_identity" "kubelet_identity" {
  name                = "${module.naming.user_assigned_identity.name}-kubelet"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.this.location
}

resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name 
  address_space       = [local.vnet_cidr]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "cluster" {
  name                 = "snet-cluster"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.cluster_nodes_subnet_cidr]
}

resource "azurerm_subnet" "api" {
  name                 = "snet-api-severver"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.cluster_api_subnet_cidir]

  delegation {
    name = "aks-delegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "this" {
  name                = module.naming.network_security_group.name 
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "port_443"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "crossplane" {
  subnet_id                 = azurerm_subnet.cluster.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_network_security_group_association" "api" {
  subnet_id                 = azurerm_subnet.api.id
  network_security_group_id = azurerm_network_security_group.this.id
}


locals {
  kubernetes_version = data.azurerm_kubernetes_service_versions.current.versions[length(data.azurerm_kubernetes_service_versions.current.versions) - 1]
  zones              = var.location == "northeurope" ? null : ["3"]
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "this" {
  lifecycle {
    ignore_changes = [
      default_node_pool.0.node_count,
    ]
  }

  name                              = module.naming.kubernetes_cluster.name 
  resource_group_name               = azurerm_resource_group.this.name
  location                          = azurerm_resource_group.this.location
  node_resource_group               = "${azurerm_resource_group.this.name}_node" 
  dns_prefix                        = local.resource_suffix 
  sku_tier                          = "Free"
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  open_service_mesh_enabled         = false
  azure_policy_enabled              = false
  local_account_disabled            = false
  role_based_access_control_enabled = true
  kubernetes_version                = data.azurerm_kubernetes_service_versions.current.latest_version 
  image_cleaner_enabled             = true
  image_cleaner_interval_hours      = 48

#   api_server_access_profile {
#     # vnet_integration_enabled = true
#     # subnet_id                = azurerm_subnet.api.id
#     #authorized_ip_ranges = local.allowed_ip_range
#   }

  linux_profile {
    admin_username = "manager"
    ssh_key {
      key_data = tls_private_key.rsa.public_key_openssh
    }
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cluster_identity.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet_identity.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet_identity.id
  }

  default_node_pool {
    name                        = "systempool"
    temporary_name_for_rotation = "systemtemp"
    node_count                  = 2
    vm_size                     = var.k8s_vm_sku
    zones                       = local.zones
    os_disk_size_gb             = 100
    vnet_subnet_id              = azurerm_subnet.cluster.id
    os_sku                      = "AzureLinux"
    os_disk_type                = "Ephemeral"
    type                        = "VirtualMachineScaleSets"
    auto_scaling_enabled        = true
    min_count                   = 1
    max_count                   = 3
    max_pods                    = 90
    node_public_ip_enabled      = false
    upgrade_settings {
      max_surge = "33%"
    }
  }

  network_profile {
    dns_service_ip      = "100.${random_integer.cluster_services_cidr.id}.0.10"
    service_cidr        = "100.${random_integer.cluster_services_cidr.id}.0.0/16"
    pod_cidr            = "100.${random_integer.cluster_pod_cidr.id}.0.0/16"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Friday"
    utc_offset  = "-06:00"
    start_time  = "20:00"
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Saturday"
    utc_offset  = "-06:00"
    start_time  = "20:00"
  }

  auto_scaler_profile {
    max_unready_nodes = "1"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
}

resource "azurerm_role_assignment" "cluster" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azuread_group.homelab_management.object_id
}

resource "azurerm_role_assignment" "crossplane_cluster_role_assignment_network_contributor" {
  scope                            = azurerm_virtual_network.this.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.cluster_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "crossplane_cluster_role_assignment_msi_owner" {
  scope                            = azurerm_user_assigned_identity.kubelet_identity.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = azurerm_user_assigned_identity.cluster_identity.principal_id
  skip_service_principal_aad_check = true
}