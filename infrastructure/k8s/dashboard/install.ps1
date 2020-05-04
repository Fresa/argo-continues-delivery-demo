If((kubectl get svc --namespace=kube-system --field-selector=metadata.name==kubernetes-dashboard --ignore-not-found) -ne $null) {
    Write-Verbose "'kubernetes-dashboard' is installed"
}
Else {
    Write-Verbose "Installing 'kubernetes-dashboard'"
    kubectl apply -f "$PSScriptRoot\install.yaml"
}