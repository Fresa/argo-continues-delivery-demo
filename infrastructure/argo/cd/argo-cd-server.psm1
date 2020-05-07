Using module "..\..\port.psm1"
Using module "..\..\trust-all-certs-policy.psm1"

class ArgoCDServer 
{
    [string]$Service = "argocd-server"
    [string]$Namespace = "argocd"
    [int]$ContainerPort = 443
    [int]$Port

    ArgoCDServer(
        [int]$port
    )
    {
        $this.Port = $port
    }

    [void] PortForward()
    {
        [Port]::Forward("svc/$($this.Service)", $this.Namespace, $this.Port, $this.ContainerPort, 120)
        Write-Host "Login with admin / $($this.GetPassword())"
    }

    [void] StopPortForwarding()
    {
        [Port]::Stop("svc/$($this.Service)")
    }

    [void] WaitUntilAvailable()
    {
        if (-not([Port]::TryWaitUntilAvailable("http://127.0.0.1:$($this.Port)")))
        {
            [Port]::OutputInfo("svc/$($this.Service)")
        }
    }

    [void] Login()
    {
        & "$PSScriptRoot/get-argocd-cli.ps1" -version 1.4.3
        argocd login 127.0.0.1:$this.Port --insecure --username admin --password $this.GetPassword()
    }

    [string] GetPassword()
    {
        return Invoke-Expression "kubectl get pods -n $($this.Namespace) -l app.kubernetes.io/name=$($this.Service) -o name" | ForEach-Object{ $_.SubString($_.IndexOf("/") + 1) }
    }
}
