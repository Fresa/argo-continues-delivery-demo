Using module "..\..\port.psm1"

class ArgoServer {
    [string]$Service = "argo-server"
    [string]$Namespace = "argo"
    [int]$ContainerPort = 2746
    [int]$Port = 2746

    [void] PortForward()
    {
        [Port]::Forward("deployment/$($this.Service)", $this.Namespace, $this.Port, $this.ContainerPort, 120)
    }

    [void] StopPortForwarding(){
        [Port]::Stop("deployment/$($this.Service)")
    }

    [void] WaitUntilAvailable(){
        if (-not([Port]::TryWaitUntilAvailable("http://127.0.0.1:$($this.Port)")))
        {
            [Port]::OutputInfo("deployment/$($this.Service)")
        }
    }
}