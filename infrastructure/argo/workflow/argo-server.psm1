Using module "..\..\port-forward.psm1"

class ArgoServer {
    [string]$Service = "argo-server"
    [string]$Namespace = "argo"
    [int]$ContainerPort = 2746
    [int]$Port = 2746
    [PortForward]$PortForwarder

    ArgoServer()
    {
        $this.PortForwarder = [PortForward]::new("deployment/$($this.Service)", $this.Namespace, $this.Port, $this.ContainerPort)
    }

    [void] PortForward()
    {
        $this.PortForwarder.Start(120)
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
}