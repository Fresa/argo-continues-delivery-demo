function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath" @args
    Write-Host
}

choco install kubernetes-cli

# Clean up
Run "stop-port-forwarding.ps1"

Run "kind\delete-cluster.ps1" -name argo-demo-test
Run "kind\delete-cluster.ps1" -name argo-demo-prod
Run "kind\delete-cluster.ps1" -name argo-demo-ci

# Install
Run "kind\create-cluster.ps1" -name argo-demo-test
Run "kind\create-cluster.ps1" -name argo-demo-prod
Run "kind\create-cluster.ps1" -name argo-demo-ci

Run "argo\events\install.ps1"
Run "argo\workflow\install.ps1"
Run "argo\cd\install.ps1"

Run "k8s\dashboard\install.ps1"
Run "k8s\dashboard\get-token.ps1"

Run "docker\registry\install.ps1"

# Port forward
Run "port-forward.ps1"

Write-Host
Get-Job | ForEach-Object {
    Write-Host $_.Name
    Receive-Job $_ -Keep
}