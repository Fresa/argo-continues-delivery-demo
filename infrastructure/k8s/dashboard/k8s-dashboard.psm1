class K8sDashboard 
{
    [string]$Name = "KubernetesProxy"
    [int]$Port

    K8sDashboard([int]$port)
    {
        $this.Port = $port
        $this.Name = "KubernetesProxy-$port"
    }

    [void] PortForward()
    {
        $command = "kubectl proxy --port=$($this.Port)"
        Start-Job -Name $this.Name -InputObject $command -ScriptBlock { 
            Invoke-Expression $input
        }
        Write-Host "Dashboard should soon be available at: http://localhost:$($this.Port)/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login"
        Write-Host "For more info: Receive-Job -Name $($this.Name)"
    }

    [void] StopPortForwarding()
    {
        Write-Host "Stopping $($this.Name)"
        if ([bool] (Get-Job -Name $this.Name -ea silentlycontinue))
         {
            Stop-Job -name $this.Name
            Remove-Job -name $this.Name
            Write-Host "$($this.Name) stopped"
        } else
        {
            Write-Warning "Could not stop $($this.Name), the job was not found"
        }
    }
}