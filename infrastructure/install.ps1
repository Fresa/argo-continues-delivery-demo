Using module ".\kind-clusters.psm1"

function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath" @args
    Write-Host
}

$clusters = [KindClusters]::new()

choco install kubernetes-cli

# Clean up
Run "stop-port-forwarding.ps1"

$clusters | ForEach-Object { 
    Run "kind\delete-cluster.ps1" -name $_.Name
}

# Install
$clusters | ForEach-Object { 
    Run "kind\create-cluster.ps1" -name $_.Name 
}

kubectl config use-context "kind-argo-demo-ci"
Run "argo\events\install.ps1"
Run "argo\workflow\install.ps1"

[KindClusters]::GetApplicationClusters() | ForEach-Object {
    kubectl config use-context $_.Context
    Run "argo\cd\install.ps1"
}

Run "docker\registry\install.ps1"

$clusters | ForEach-Object {
    kubectl config use-context $_.Context
    Run "k8s\dashboard\install.ps1"
    Run "k8s\dashboard\get-token.ps1"
}

# Port forward
Run "port-forward.ps1"

Write-Host
Get-Job | ForEach-Object {
    Write-Host "$($_.Id) | $($_.Name) | State: $($_.State)" -ForegroundColor Green
    Receive-Job $_
}