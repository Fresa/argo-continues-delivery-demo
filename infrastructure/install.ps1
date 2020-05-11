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
$ciCluster.ArgoEvents.Install()
$ciCluster.Argo.Install()
$ciCluster.Argo.DownloadCLI("2.7.5")
$ciCluster.DockerRegistry.Install()

$applicationClusters | ForEach-Object {
    $_.UseContext()
    $_.ArgoCD.Install()
    $_.ArgoCD.DownloadCLI("1.4.3")
}

Run "port-forward.ps1"

# Create CD
$applicationClusters | ForEach-Object {
    $_.UseContext()
    $_.CreateDemoApp()
}

Write-Host
Get-Job | ForEach-Object {
    Write-Host "$($_.Id) | $($_.Name) | State: $($_.State)" -ForegroundColor Green
}