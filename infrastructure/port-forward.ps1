Using module ".\kind-clusters.psm1"

function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath" @args
    Write-Host
}

$clusters = [KindClusters]::new()

kubectl config use-context "kind-argo-demo-ci"
Run "argo\workflow\start-ui.ps1"
Run "argo\events\port-forward-gateway.ps1"

Run "docker\registry\port-forward.ps1"

$port = 8080
[KindClusters]::GetApplicationClusters() | ForEach-Object {
    kubectl config use-context $_.Context
    Run "argo\cd\start-ui.ps1" -port $port
    $port++
}

$clusters | ForEach-Object {
    kubectl config use-context $_.Context
    Run "k8s\dashboard\start.ps1" -port $_.Port
}

Write-Host
Get-Job | ForEach-Object {
    Write-Host $_.Name -ForegroundColor Green
    Receive-Job $_
}