function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath" @args
    Write-Host
}

# Port forward
Run "k8s\dashboard\start.ps1"

Run "argo\workflow\start-ui.ps1"
Run "argo\cd\start-ui.ps1"
Run "argo\events\port-forward-gateway.ps1"

Run "docker\registry\port-forward.ps1"

Write-Host
Get-Job | ForEach-Object {
    Write-Host $_.Name
    Receive-Job $_
}