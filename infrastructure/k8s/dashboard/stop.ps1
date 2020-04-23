$name = "KubernetesProxy"
Write-Host "Stopping $name"
Get-Job -name "$name*" | Stop-Job
Get-Job -name "$name*" | Remove-Job
Write-Host "$name stopped"