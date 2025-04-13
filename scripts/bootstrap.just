set shell := ["pwsh.exe", "-c"]
set working-directory := '../bootstrap'

default: deploy

init:
    terraform init -backend-config="./config/yesehdev.tfbackend" 

plan: init
    terraform plan -out tfplan -var-file="./config/yesehdev.tfvars"

plan-destroy: init
    terraform plan -out tfplan -destroy -var-file="./config/yesehdev.tfvars"

deploy: plan
    terraform apply -auto-approve tfplan

destroy: plan-destroy
    terraform apply -auto-approve tfplan
