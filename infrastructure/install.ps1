function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath"
    Write-Host
}

# Clean up
Run "k8s\dashboard\stop.ps1"

Run "argo\workflow\stop-ui.ps1"
Run "argo\cd\stop-ui.ps1"
Run "argo\events\stop-port-forwarding-gateway.ps1"

Run "kind\delete-cluster.ps1"

# Install
Run "kind\create-cluster.ps1"

Run "argo\events\install.ps1"
Run "argo\workflow\install.ps1"
Run "argo\cd\install.ps1"

Run "k8s\dashboard\install.ps1"
Run "k8s\dashboard\start.ps1"
Run "k8s\dashboard\get-token.ps1"

Run "argo\workflow\start-ui.ps1"
Run "argo\cd\start-ui.ps1"
Run "argo\events\port-forward-gateway.ps1"

Write-Host
Get-Job | ForEach-Object {
    Write-Host $_.Name
    Receive-Job $_ -Keep
}