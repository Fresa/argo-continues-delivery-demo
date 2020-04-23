Using module "..\..\port.psm1"

$service = "argocd-server"
$namespace = "argocd"
$timeout="120s";

Write-Host "Waiting max $timeout for deployment/$service in namespace $namespace to become available..."
kubectl wait --for=condition=available --timeout=$timeout deployment/$service -n $Namespace

[Port]::Forward("svc/$service", $namespace, 8080, 443)

$password = kubectl get pods -n $namespace -l app.kubernetes.io/name=$service -o name | ForEach-Object{ $_.SubString($_.IndexOf("/") + 1) }
Write-Host "Login with admin / $password"