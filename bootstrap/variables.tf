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