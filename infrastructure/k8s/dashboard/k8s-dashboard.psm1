Using module "..\..\log.psm1"

class K8sDashboard 
{
    [string]$Name = "KubernetesProxy"
    [int]$Port
    [Log]$Log = [Log]::new([K8sDashboard])

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
        $this.Log.Info("Dashboard should soon be available at: http://localhost:$($this.Port)/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login")
        $this.Log.Info("For more info: Receive-Job -Name $($this.Name)")
    }

    [void] StopPortForwarding()
    {
        $this.Log.Info("Stopping $($this.Name)")
        if ([bool] (Get-Job -Name $this.Name -ea silentlycontinue))
         {
            Stop-Job -name $this.Name
            Remove-Job -name $this.Name
            $this.Log.Info("$($this.Name) stopped")
        } else
        {
            $this.Log.Warning("Could not stop $($this.Name), the job was not found")
        }
    }
}