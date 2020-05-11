Using module ".\kind-clusters.psm1"

$clusters = [KindClusters]::new()
$applicationClusters = $clusters.GetApplicationClusters()
$ciCluster = $clusters.GetCICluster()

$clusters | ForEach-Object {
    $_.UseContext()
    $_.Dashboard.PortForward()
    Write-Host
}

$ciCluster.UseContext()
$ciCluster.ArgoServer.PortForward()
$ciCluster.ArgoServer.WaitUntilAvailable()
Write-Host
$ciCluster.CodePushedGateway.PortForward()
$ciCluster.CodePushedGateway.WaitUntilAvailable()
Write-Host
$ciCluster.DockerRegistry.PortForward()
$ciCluster.DockerRegistry.WaitUntilAvailable()
Write-Host

$applicationClusters | ForEach-Object {
    $_.UseContext()
    $_.ArgoCDServer.PortForward()
    $_.ArgoCDServer.WaitUntilAvailable()
    Write-Host
}