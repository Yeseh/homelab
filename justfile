set shell := ["pwsh.exe", "-CommandWithArgs"]

mod bootstrap './scripts/bootstrap.just'

foo bla:
    Write-Output {{bla}}