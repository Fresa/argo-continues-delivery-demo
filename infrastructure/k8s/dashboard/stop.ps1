param(
    [parameter(Mandatory=$true,
        HelpMessage="Port the dashboard is listening on")]
    [String]$port
)

$name = "KubernetesProxy-$port"
Write-Host "Stopping $name"
Get-Job -name "$name*" | Stop-Job
Get-Job -name "$name*" | Remove-Job
Write-Host "$name stopped"