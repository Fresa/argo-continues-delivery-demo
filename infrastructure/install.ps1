Using module ".\kind-clusters.psm1"

function Run($relativePath) {
    Write-Host
    & "$PSScriptRoot\$relativePath" @args
    Write-Host
}

if (-not(Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$clusters = [KindClusters]::new()
$applicationClusters = $clusters.GetApplicationClusters()
$ciCluster = $clusters.GetCICluster()

choco install kubernetes-cli

# Clean up
Run "stop-port-forwarding.ps1"

$clusters | ForEach-Object { 
    $_.Delete()
}

# Install
$clusters | ForEach-Object { 
    $_.Create()
    Write-Host
    $_.Dashboard.Install()
    Write-Host
}

$ciCluster.UseContext()
Run "argo\events\install.ps1"
$ciCluster.ArgoServer.Install()
$ciCluster.DockerRegistry.Install()

$applicationClusters | ForEach-Object {
    $_.UseContext()
    Run "argo\cd\install.ps1"
}

# Create CI
$ciCluster.UseContext()
Run "argo\events\setup-ci.ps1"

# Port forward
Run "port-forward.ps1"

# Create CD
$applicationClusters | ForEach-Object {
    $_.UseContext()
    Run "argo\cd\create-demo-app.ps1" -environment $_.Environment -argoCDServer $_.ArgoCDServer
}

Write-Host
Get-Job | ForEach-Object {
    Write-Host "$($_.Id) | $($_.Name) | State: $($_.State)" -ForegroundColor Green
}