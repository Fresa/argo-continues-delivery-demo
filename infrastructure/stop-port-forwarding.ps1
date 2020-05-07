Using module ".\kind-clusters.psm1"

$clusters = [KindClusters]::new()
$applicationClusters = $clusters.GetApplicationClusters()
$ciCluster = $clusters.GetCICluster()

$ciCluster.ArgoServer.StopPortForwarding()
$ciCluster.CodePushedGateway.StopPortForwarding()
$ciCluster.DockerRegistry.StopPortForwarding()

$applicationClusters | ForEach-Object {
    $_.ArgoCDServer.StopPortForwarding()
}

$clusters | ForEach-Object {
    $_.Dashboard.StopPortForwarding()
}