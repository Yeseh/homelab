

# Homelab

My kubernetes homelab.

## Features

- Azure infrastructure deployments with Azure Service Operator
- Azure KeyVault Secret synchronization with external-secrets
- TODO: Multi Tenant FluxCD
- TODO: Source control (GitHub) provisioning
- TODO: Decentralized app networking with Gateway API 

### Bootstrap
The bootstrap procedure is responsible for creating the minimal set of azure resources to run fluxcd + azure service operator to deploy azure resources.
The end state is an azure kubernetes service with fluxCD bootstrapped to a github repository. From that point forward, Flux is responsible for managing everything going on in the cluster.

Flux has a couple of prerequisites:
- A target kubernetes cluster
- Access to certain information from bootstrap to configure ASO:
    - The 'master' azure service operator managed identity 
    - Platform subscription id 
    - platform tenant id

The required information is captured in the following variables:
- platformKeyvaultUri: the uri to the bootstrap keyvault
- platformExternalSecretsClientId: client id of the managed identity that is used to read secrets from the bootstrap keyvault
- platformNamespace: namespace of the platform
- platformTenantId: azure tenant in which the platform resides
- platformSubscriptionId: azure subscription that contains the platform resources
- platformExternalSecretsServiceAccountName: service account name for the external secrets operator

Above variables are stored in a config map in the homelab-system namespace.
The flux kustomize-controller is then granted access to this config map in order to substitute the config values into the k8s infrastructure configuration.


## Tools

- Kubectl
- Kubecolor
- Keyverno cli

## Cluster Authorization 

- A flux cd tenant MUST have a service account tied to it
    - This sa is federated with the azure deployment managed identity
- Kustomizations/Helmreleases in fluxcd tenants MUST specify a service account 
- Flux cd tenants MUST not expose kro.run/v1alpha1/ResourceGraphDefinition to consumers
    - Only instances should be allowed