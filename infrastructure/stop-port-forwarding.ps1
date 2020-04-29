function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath" @args
    Write-Host
}

Run "k8s\dashboard\stop.ps1"

Run "argo\workflow\stop-ui.ps1"
Run "argo\cd\stop-ui.ps1"
Run "argo\events\stop-port-forwarding-gateway.ps1"

Run "docker\registry\stop-port-forwarding.ps1"