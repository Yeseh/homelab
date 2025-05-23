provider "github" {
  owner = var.github_org
  token = var.github_token
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = var.github_repo
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

# resource "flux_bootstrap_git" "this" {
#   depends_on = [github_repository_deploy_key.this]

#   path = "clusters/production"
# }