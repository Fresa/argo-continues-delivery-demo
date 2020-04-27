Using module "..\..\port.psm1"

$resource = "docker-registry"
$namespace = "default"
$timeout = "120s"

Write-Host "Waiting max $timeout for pod/$resource in namespace $namespace to become available..."
kubectl wait --for=condition=ready --timeout=$timeout "pod/$resource" -n $namespace

[Port]::Forward("service/$resource", $namespace, 5001, 5000)