Using module "..\..\port.psm1"

[Port]::Forward("svc/argocd-server", "argocd", 8080, 443)

$password = kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | ForEach-Object{ $_.SubString($_.IndexOf("/") + 1) }
Write-Host "Login with admin / $password"