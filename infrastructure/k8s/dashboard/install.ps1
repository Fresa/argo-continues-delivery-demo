If((kubectl get svc --namespace=kube-system --field-selector=metadata.name==kubernetes-dashboard --ignore-not-found) -ne $null) {
    Write-Verbose "'kubernetes-dashboard' is installed"
}
Else {
    Write-Verbose "Installing 'kubernetes-dashboard'"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
}

Write-Host "Creating admin user for 'kubernetes-dashboard'"
kubectl apply -f "$PSScriptRoot\serviceaccount.yaml"