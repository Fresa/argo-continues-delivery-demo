param(
    [parameter(Mandatory=$true,
        HelpMessage="Port to expose the dashboard through")]
    [String]$port
)

$command = "kubectl proxy --port=$port"
Start-Job -Name KubernetesProxy-$port -InputObject $command -ScriptBlock { 
    Invoke-Expression $input
}
Write-Host "Dashboard available at: http://localhost:$port/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login"