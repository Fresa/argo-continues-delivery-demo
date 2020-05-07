Using module ".\kind-clusters.psm1"

$clusters = [KindClusters]::new()
$applicationClusters = $clusters.GetApplicationClusters()
$ciCluster = $clusters.GetCICluster()

# Start port forwarding
$ciCluster.UseContext()
$ciCluster.ArgoServer.PortForward()
Write-Host
$ciCluster.CodePushedGateway.PortForward()
Write-Host
$ciCluster.DockerRegistry.PortForward()
Write-Host

$applicationClusters | ForEach-Object {
    $_.UseContext()
    $_.ArgoCDServer.PortForward()
    Write-Host
}

$clusters | ForEach-Object {
    $_.UseContext()
    $_.Dashboard.PortForward()
    Write-Host
}

# Wait until services are available
$ciCluster.UseContext()
$ciCluster.ArgoServer.WaitUntilAvailable()
Write-Host
$ciCluster.CodePushedGateway.WaitUntilAvailable()
Write-Host
$ciCluster.DockerRegistry.WaitUntilAvailable()
Write-Host

$applicationClusters | ForEach-Object {
    $_.UseContext()
    $_.ArgoCDServer.WaitUntilAvailable()
    Write-Host
}