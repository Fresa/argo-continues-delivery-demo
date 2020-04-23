Using module "..\..\port.psm1"

$resource = "deployment/code-pushed-gateway"
$namespace = "argo-events"
$timeout = "120s"

Write-Host "Waiting max $timeout for $resource in namespace $namespace to become available..."
kubectl wait --for=condition=available --timeout=$timeout $resource -n $namespace

[Port]::Forward($resource, $namespace, 12000, 12000)