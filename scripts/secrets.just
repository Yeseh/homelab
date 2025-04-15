set shell := ["pwsh.exe", "-c"]

get namespace secretName key:
    kubectl get secret {{secretName}} -o jsonpath="{.data.{{key}}}" -n {{namespace}} | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) } 
