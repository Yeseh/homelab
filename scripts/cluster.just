set shell := ["pwsh.exe", "-c"]

clusterName := "aks-ydhomelab"
resourceGroup := "rg-ydhomelab"

login:
    az aks get-credentials --name {{clusterName}} --resource-group {{resourceGroup}} --format azure

use: login
    kubectl config use-context {{clusterName}}

stop:
    az aks stop --name {{clusterName}} --resource-group {{resourceGroup}}

start:
    az aks start --name {{clusterName}} --resource-group {{resourceGroup}}
    