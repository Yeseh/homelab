variable "subscription_id" {
    type = string
    description = "Azure subscription to deploy to"
}

variable "tenant_id" {
    type = string
    description = "Azure tenant to deploy to"
}

variable "location" {
    type = string
    default = "westeurope"
    description = "Azure location to deploy to"
}

variable "k8s_vm_sku" {
  description = "The VM type for the system node pool"
  default     = "Standard_D4ads_v5"
}