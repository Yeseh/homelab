set shell := ["pwsh.exe", "-CommandWithArgs"]

# Bootstrap cloud resources using terraform
mod bootstrap './scripts/bootstrap.just'

# Interface with the homelab controlplane cluster 
mod cluster './scripts/cluster.just'

foo bla:
    Write-Output {{bla}}