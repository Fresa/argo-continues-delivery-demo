function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath" @args
    Write-Host
}

Run "define-variables.ps1"

kubectl config use-context "kind-argo-demo-ci"
Run "argo\workflow\start-ui.ps1"
Run "argo\cd\start-ui.ps1"
Run "argo\events\port-forward-gateway.ps1"

Run "docker\registry\port-forward.ps1"

$port = 8001
$contexts | ForEach-Object {
    kubectl config use-context $_
    Run "k8s\dashboard\start.ps1" -port $port
    $port++
}

Write-Host
Get-Job | ForEach-Object {
    Write-Host $_.Name -ForegroundColor Green
    Receive-Job $_
}