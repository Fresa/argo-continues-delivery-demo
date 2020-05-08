Using module "..\..\port-forward.psm1"
Using module "..\..\trust-all-certs-policy.psm1"

class ArgoCDServer 
{
    [string]$Service = "argocd-server"
    [string]$Namespace = "argocd"
    [int]$ContainerPort = 443
    [PortForward]$PortForwarder

    ArgoCDServer(
        [int]$port
    )
    {
        $this.PortForwarder = [PortForward]::new("svc/$($this.Service)", $this.Namespace, $port, $this.ContainerPort)
    }

    [void] PortForward()
    {
        $this.PortForwarder.Start(120)
        Write-Host "Login with admin / $($this.GetPassword())"
    }

    [void] StopPortForwarding()
    {
        $this.PortForwarder.Stop()
    }

    [void] WaitUntilAvailable()
    {
        if (-not($this.PortForwarder.TryWaitUntilAvailable("http://127.0.0.1:$($this.PortForwarder.From)")))
        {
            $this.PortForwarder.OutputInfo()
        }
    }

    [void] Login()
    {
        & "$PSScriptRoot/get-argocd-cli.ps1" -version 1.4.3
        argocd login 127.0.0.1:$this.PortForwarder.From --insecure --username admin --password $this.GetPassword()
    }

    [string] GetPassword()
    {
        return Invoke-Expression "kubectl get pods -n $($this.Namespace) -l app.kubernetes.io/name=$($this.Service) -o name" | ForEach-Object{ $_.SubString($_.IndexOf("/") + 1) }
    }
}
