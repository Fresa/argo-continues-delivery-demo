function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath" @args
    Write-Host
}

Run "define-variables.ps1"

kubectl config use-context "kind-argo-demo-ci"
Run "argo\workflow\stop-ui.ps1"
Run "argo\cd\stop-ui.ps1"
Run "argo\events\stop-port-forwarding-gateway.ps1"

Run "docker\registry\stop-port-forwarding.ps1"

$port = 8001
$contexts | ForEach-Object {
    kubectl config use-context $_
    Run "k8s\dashboard\stop.ps1" -port $port
    $port++
}